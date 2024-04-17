defmodule HomeVisit.Repo do
  @moduledoc """
  Functions that interact directly with the underlying data store.
  """
  use Ecto.Repo,
    adapter: Ecto.Adapters.SQLite3,
    otp_app: :home_visit
end
