defmodule HomeVisit.Api.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table("transactions") do
      add :pal_id, references("users"), null: false
      add :visit_id, references("visits"), null: false
      add :fulfilled_at, :naive_datetime, null: false

      timestamps()
    end
  end
end
