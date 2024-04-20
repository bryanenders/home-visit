defmodule HomeVisit.Api.UserTest do
  use ExUnit.Case, async: true

  alias HomeVisit.Api.User
  import HomeVisit.ChangesetHelpers

  test "%User{} has a default balance" do
    user = %User{}

    assert 0 === user.balance
  end

  describe "changeset/2" do
    @user %User{registered_at: ~N[1970-01-01 00:00:00]}
    @valid_params %{
      first_name: "Alice",
      last_name: "Quinn",
      email: "alice.quinn@brakebills.edu",
      balance: 3
    }

    test "applies the params as changes" do
      changeset = User.changeset(@user, @valid_params)

      assert %Ecto.Changeset{} = changeset
      assert @user === changeset.data
      assert changeset.valid?

      assert @valid_params.first_name === changeset.changes.first_name
      assert @valid_params.last_name === changeset.changes.last_name
      assert @valid_params.email === changeset.changes.email
      assert @valid_params.balance === changeset.changes.balance
    end

    test "checks for a unique email constraint" do
      changeset = User.changeset(@user, @valid_params)

      assert Enum.any?(changeset.constraints, fn c ->
               c.field === :email and
                 c.type === :unique and
                 c.error_message === "has already been taken"
             end)
    end

    test "with extraneous params" do
      extraneous_params = %{
        discipline: "phosphoromancy",
        registered_at: NaiveDateTime.add(@user.registered_at, 1, :day)
      }

      params = Map.merge(@valid_params, extraneous_params)

      changeset = User.changeset(@user, params)
      assert changeset.valid?

      refute Map.has_key?(changeset.changes, :discipline)
      refute Map.has_key?(changeset.changes, :registered_at)
    end

    test "without balance" do
      params = Map.delete(@valid_params, :balance)

      changeset = User.changeset(@user, params)

      assert changeset.valid?
    end

    test "without first name" do
      for params <- [
            Map.delete(@valid_params, :first_name),
            Map.put(@valid_params, :first_name, nil)
          ] do
        changeset = User.changeset(@user, params)
        refute changeset.valid?

        assert "can't be blank" in errors_on(changeset).first_name
      end
    end

    test "without last name" do
      for params <- [
            Map.delete(@valid_params, :last_name),
            Map.put(@valid_params, :last_name, nil)
          ] do
        changeset = User.changeset(@user, params)
        refute changeset.valid?

        assert "can't be blank" in errors_on(changeset).last_name
      end
    end

    test "without email" do
      for params <- [
            Map.delete(@valid_params, :email),
            Map.put(@valid_params, :email, nil)
          ] do
        changeset = User.changeset(@user, params)
        refute changeset.valid?

        assert "can't be blank" in errors_on(changeset).email
      end
    end

    test "with a nil balance" do
      params = Map.put(@valid_params, :balance, nil)

      changeset = User.changeset(@user, params)
      refute changeset.valid?

      assert "can't be blank" in errors_on(changeset).balance
    end

    test "with a negative balance" do
      params = Map.put(@valid_params, :balance, -1)

      changeset = User.changeset(@user, params)
      refute changeset.valid?

      assert "can't be negative" in errors_on(changeset).balance
    end
  end
end
