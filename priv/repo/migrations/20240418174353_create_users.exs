defmodule HomeVisit.Api.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table("users") do
      add :first_name, :string, null: false
      add :last_name, :string, null: false
      add :email, :string, collate: :nocase, null: false
      add :registered_at, :naive_datetime, null: false

      timestamps()
    end

    create unique_index("users", [:email])
  end
end
