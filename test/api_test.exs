defmodule HomeVisit.ApiTest do
  use ExUnit.Case, async: false

  alias HomeVisit.Api
  import Ecto.Query, only: [from: 2]
  import HomeVisit.ChangesetHelpers

  @member_email "member@example.com"

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Api.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(Api.Repo, {:shared, self()})
  end

  doctest Api

  describe "fulfill_visit/2" do
    @pal_email "pal@example.com"
    @member_balance_and_visit_minutes 20

    setup do
      :ok = register_user(@member_email, @member_balance_and_visit_minutes)
      :ok = register_user(@pal_email, 0)
      %{visit_id: request_visit(@member_balance_and_visit_minutes)}
    end

    test "records the transaction", %{visit_id: visit_id} do
      assert :ok === Api.fulfill_visit(@pal_email, visit_id)

      assert [transaction] = transactions()
      assert @pal_email === transaction.pal.email
      assert visit_id === transaction.visit_id
      assert visit_id === transaction.visit.id
      assert 1 >= NaiveDateTime.diff(NaiveDateTime.utc_now(), transaction.fulfilled_at)
    end

    test "debits the member at 100%", %{visit_id: visit_id} do
      :ok = Api.fulfill_visit(@pal_email, visit_id)

      assert 0 === balance(@member_email)
    end

    test "credits the pal at 85%", %{visit_id: visit_id} do
      :ok = Api.fulfill_visit(@pal_email, visit_id)

      assert ceil(@member_balance_and_visit_minutes * 0.85) == balance(@pal_email)
    end

    test "rounds up the amount credited to the pal" do
      minutes = 6
      visit_id = request_visit(minutes)

      :ok = Api.fulfill_visit(@pal_email, visit_id)

      assert 6 === balance(@pal_email)
    end

    test "with an unregistered pal email", %{visit_id: visit_id} do
      assert {:error, :pal_not_found} === Api.fulfill_visit("unregistered@example.com", visit_id)

      assert [] = transactions()
    end

    test "with an unknown visit ID" do
      assert {:error, :visit_not_found} === Api.fulfill_visit(@pal_email, 123)

      assert [] = transactions()
    end
  end

  describe "register_user/1" do
    @valid_params %{
      first_name: "fake first name",
      last_name: "fake last name",
      email: "fake@example.com",
      balance: 50
    }

    test "registers the user" do
      assert :ok === Api.register_user(@valid_params)

      assert [user] = users()
      assert @valid_params.first_name === user.first_name
      assert @valid_params.last_name === user.last_name
      assert @valid_params.email === user.email
      assert @valid_params.balance === user.balance
      assert 1 >= NaiveDateTime.diff(NaiveDateTime.utc_now(), user.registered_at)
    end

    test "with extraneous params" do
      extraneous_params = %{
        middle_name: "fake middle name",
        registered_at: ~N[1970-01-01 00:00:01]
      }

      params = Map.merge(@valid_params, extraneous_params)

      :ok = Api.register_user(params)

      assert [user] = users()
      assert 1 >= NaiveDateTime.diff(NaiveDateTime.utc_now(), user.registered_at)
    end

    test "with a default balance" do
      params = Map.delete(@valid_params, :balance)

      :ok = Api.register_user(params)

      assert [user] = users()
      assert 0 === user.balance
    end

    test "without first name" do
      for params <- [
            Map.delete(@valid_params, :first_name),
            Map.put(@valid_params, :first_name, nil)
          ] do
        assert {:error, changeset} = Api.register_user(params)
        assert "can't be blank" in errors_on(changeset).first_name

        assert [] = users()
      end
    end

    test "without last name" do
      for params <- [
            Map.delete(@valid_params, :last_name),
            Map.put(@valid_params, :last_name, nil)
          ] do
        assert {:error, changeset} = Api.register_user(params)
        assert "can't be blank" in errors_on(changeset).last_name

        assert [] = users()
      end
    end

    test "without email" do
      for params <- [
            Map.delete(@valid_params, :email),
            Map.put(@valid_params, :email, nil)
          ] do
        assert {:error, changeset} = Api.register_user(params)
        assert "can't be blank" in errors_on(changeset).email

        assert [] = users()
      end
    end

    test "with a nil balance" do
      params = Map.put(@valid_params, :balance, nil)

      assert {:error, changeset} = Api.register_user(params)
      assert "can't be blank" in errors_on(changeset).balance

      assert [] = users()
    end

    test "with a negative balance" do
      params = Map.put(@valid_params, :balance, -1)

      assert {:error, changeset} = Api.register_user(params)
      assert "can't be negative" in errors_on(changeset).balance

      assert [] = users()
    end

    test "with an email that is already registered" do
      :ok = Api.register_user(@valid_params)

      params = %{
        first_name: "another first name",
        last_name: "another last name",
        email: @valid_params.email
      }

      assert {:error, changeset} = Api.register_user(params)
      assert "has already been taken" in errors_on(changeset).email
    end
  end

  describe "request_visit/2" do
    @member_balance 60
    @valid_params %{
      date: ~D[2063-04-05],
      minutes: @member_balance,
      tasks: "make contact"
    }

    setup do
      :ok = register_user(@member_email, @member_balance)
    end

    test "requests the visit" do
      assert {:ok, visit_id} = Api.request_visit(@member_email, @valid_params)

      assert [visit] = visits()
      assert visit_id === visit.id
      assert @valid_params.date === visit.date
      assert @valid_params.minutes === visit.minutes
      assert @valid_params.tasks === visit.tasks
      assert @member_email === visit.member.email
      assert 1 >= NaiveDateTime.diff(NaiveDateTime.utc_now(), visit.requested_at)
    end

    test "with extraneous params" do
      extraneous_params = %{
        hours: 24,
        requested_at: ~N[1970-01-01 00:00:01]
      }

      params = Map.merge(@valid_params, extraneous_params)

      {:ok, _} = Api.request_visit(@member_email, params)

      assert [visit] = visits()
      assert 1 >= NaiveDateTime.diff(NaiveDateTime.utc_now(), visit.requested_at)
    end

    test "with an unregistered member email" do
      assert {:error, :member_not_found} ===
               Api.request_visit("unregistered@example.com", @valid_params)

      assert [] = visits()
    end

    test "without date param" do
      for params <- [
            Map.delete(@valid_params, :date),
            Map.put(@valid_params, :date, nil)
          ] do
        assert {:error, changeset} = Api.request_visit(@member_email, params)
        assert "can't be blank" in errors_on(changeset).date

        assert [] = visits()
      end
    end

    test "without minutes param" do
      for params <- [
            Map.delete(@valid_params, :minutes),
            Map.put(@valid_params, :minutes, nil)
          ] do
        assert {:error, changeset} = Api.request_visit(@member_email, params)
        assert "can't be blank" in errors_on(changeset).minutes

        assert [] = visits()
      end
    end

    test "without tasks param" do
      for params <- [
            Map.delete(@valid_params, :tasks),
            Map.put(@valid_params, :tasks, nil)
          ] do
        assert {:error, changeset} = Api.request_visit(@member_email, params)
        assert "can't be blank" in errors_on(changeset).tasks

        assert [] = visits()
      end
    end

    test "with minutes param below 1" do
      params = Map.put(@valid_params, :minutes, 0)

      assert {:error, changeset} = Api.request_visit(@member_email, params)
      assert "must be greater than 0" in errors_on(changeset).minutes

      assert [] = visits()
    end

    test "when the balance of the member cannot cover the visit" do
      params = Map.put(@valid_params, :minutes, @member_balance + 1)

      assert {:error, changeset} = Api.request_visit(@member_email, params)
      assert "can't exceed member balance" in errors_on(changeset).minutes

      assert [] = visits()
    end
  end

  @spec balance(Api.email()) :: Api.User.balance()
  defp balance(email) when is_binary(email),
    do: Api.Repo.one!(from u in "users", where: u.email == ^email, select: u.balance)

  @spec register_user(Api.email(), Api.User.balance()) :: :ok
  defp register_user(email, balance)
       when is_binary(email) and is_integer(balance) and balance >= 0 do
    :ok =
      Api.register_user(%{
        first_name: "Fakie",
        last_name: "Fakerson",
        email: email,
        balance: balance
      })
  end

  @spec request_visit(integer) :: Api.visit_id()
  defp request_visit(minutes) when is_integer(minutes) do
    {:ok, visit_id} =
      Api.request_visit(@member_email, %{
        date: ~D[1970-01-01],
        minutes: minutes,
        tasks: "fake tasks"
      })

    visit_id
  end

  @spec transactions :: [Api.Transaction.t()]
  defp transactions,
    do:
      Api.Transaction
      |> Api.Repo.all()
      |> Api.Repo.preload([:pal, :visit])

  @spec users :: [Api.User.t()]
  defp users,
    do: Api.Repo.all(Api.User)

  @spec visits :: [Api.Visit.t()]
  defp visits,
    do:
      Api.Visit
      |> Api.Repo.all()
      |> Api.Repo.preload(:member)
end
