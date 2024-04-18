defmodule HomeVisit.Application do
  @moduledoc false
  use Application

  alias HomeVisit.Api

  @impl true
  def start(_type, _args) do
    children = [
      Api.Repo
    ]

    opts = [
      name: HomeVisit.Supervisor,
      strategy: :one_for_one
    ]

    Supervisor.start_link(children, opts)
  end
end
