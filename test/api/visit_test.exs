defmodule HomeVisit.Api.VisitTest do
  use ExUnit.Case, async: true

  alias HomeVisit.Api.Visit
  import HomeVisit.ChangesetHelpers

  describe "changeset/2" do
    @visit %Visit{member_id: 1, requested_at: ~N[1970-01-01 00:00:00]}
    @valid_params %{
      date: ~D[1970-01-01],
      minutes: 1,
      tasks: "Some tasks"
    }
    @member_balance 10

    test "applies the params as changes" do
      changeset = Visit.changeset(@visit, @member_balance, @valid_params)

      assert %Ecto.Changeset{} = changeset
      assert @visit === changeset.data
      assert changeset.valid?

      assert @valid_params.date === changeset.changes.date
      assert @valid_params.minutes === changeset.changes.minutes
      assert @valid_params.tasks === changeset.changes.tasks
    end

    test "with extraneous params" do
      extraneous_params = %{
        forecast: "partly cloudy",
        requested_at: NaiveDateTime.add(@visit.requested_at, 1, :day)
      }

      params = Map.merge(@valid_params, extraneous_params)

      changeset = Visit.changeset(@visit, @member_balance, params)
      assert changeset.valid?

      refute Map.has_key?(changeset.changes, :discipline)
      refute Map.has_key?(changeset.changes, :requested_at)
    end

    test "without date" do
      for params <- [
            Map.delete(@valid_params, :date),
            Map.put(@valid_params, :date, nil)
          ] do
        changeset = Visit.changeset(@visit, @member_balance, params)
        refute changeset.valid?

        assert "can't be blank" in errors_on(changeset).date
      end
    end

    test "without minutes" do
      for params <- [
            Map.delete(@valid_params, :minutes),
            Map.put(@valid_params, :minutes, nil)
          ] do
        changeset = Visit.changeset(@visit, @member_balance, params)
        refute changeset.valid?

        assert "can't be blank" in errors_on(changeset).minutes
      end
    end

    test "without tasks" do
      for params <- [
            Map.delete(@valid_params, :tasks),
            Map.put(@valid_params, :tasks, nil)
          ] do
        changeset = Visit.changeset(@visit, @member_balance, params)
        refute changeset.valid?

        assert "can't be blank" in errors_on(changeset).tasks
      end
    end

    test "with minutes below 1" do
      params = Map.put(@valid_params, :minutes, 0)

      changeset = Visit.changeset(@visit, @member_balance, params)
      refute changeset.valid?

      assert "must be greater than 0" in errors_on(changeset).minutes
    end

    test "with minutes in excess of the member balance" do
      params = Map.put(@valid_params, :minutes, @member_balance + 1)

      changeset = Visit.changeset(@visit, @member_balance, params)
      assert "can't exceed member balance" in errors_on(changeset).minutes
    end
  end
end
