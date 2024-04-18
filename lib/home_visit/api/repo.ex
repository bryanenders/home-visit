defmodule HomeVisit.Api.Repo do
  @moduledoc """
  Functions that interact directly with the data store underlying the API
  bounded context.
  """
  use Ecto.Repo,
    adapter: Ecto.Adapters.SQLite3,
    otp_app: :home_visit
end
