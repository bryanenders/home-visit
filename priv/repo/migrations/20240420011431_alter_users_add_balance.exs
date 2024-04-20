defmodule HomeVisit.Api.Repo.Migrations.AlterUsersAddBalance do
  use Ecto.Migration

  def change do
    alter table("users") do
      add :balance, :integer, default: 0, null: false
    end
  end
end
