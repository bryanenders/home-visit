defmodule HomeVisit.ApiTest do
  use ExUnit.Case, async: false

  alias HomeVisit.Api

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Api.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(Api.Repo, {:shared, self()})
  end

  doctest Api
end
