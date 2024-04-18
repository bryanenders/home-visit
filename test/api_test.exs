defmodule HomeVisit.ApiTest do
  use ExUnit.Case, async: false

  alias HomeVisit.Api

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Api.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(Api.Repo, {:shared, self()})
  end

  doctest Api

  describe "register_user/1" do
    @valid_params %{
      first_name: "fake first name",
      last_name: "fake last name",
      email: "fake@example.com"
    }

    test "registers the user" do
      assert :ok === Api.register_user(@valid_params)

      assert [user] = users()
      assert @valid_params.first_name === user.first_name
      assert @valid_params.last_name === user.last_name
      assert @valid_params.email === user.email
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
    @member_email "member@example.com"
    @valid_params %{
      date: ~D[2063-04-05],
      minutes: 60,
      tasks: "make contact"
    }

    setup do
      :ok =
        Api.register_user(%{
          first_name: "fake first name",
          last_name: "fake last name",
          email: @member_email
        })
    end

    test "requests the visit" do
      assert :ok = Api.request_visit(@member_email, @valid_params)

      assert [visit] = visits()
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

      :ok = Api.request_visit(@member_email, params)

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
  end

  @spec errors_on(Ecto.Changeset.t()) :: %{optional(atom) => [String.t(), ...]}
  defp errors_on(%Ecto.Changeset{} = changeset),
    do: Ecto.Changeset.traverse_errors(changeset, fn {message, _} -> message end)

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
