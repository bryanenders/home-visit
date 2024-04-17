defmodule HomeVisit.Application do
  @moduledoc false
  use Application

  alias HomeVisit.Repo

  @impl true
  def start(_type, _args) do
    children = [
      Repo
    ]

    opts = [
      name: HomeVisit.Supervisor,
      strategy: :one_for_one
    ]

    Supervisor.start_link(children, opts)
  end
end
