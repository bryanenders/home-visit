defmodule HomeVisit.Api.Repo.Migrations.CreateVisits do
  use Ecto.Migration

  def change do
    create table("visits") do
      add :date, :date, null: false
      add :minutes, :integer, null: false
      add :tasks, :string, null: false
      add :requested_at, :naive_datetime, null: false

      add :member_id, references("users"), null: false

      timestamps()
    end
  end
end
