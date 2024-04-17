defmodule HomeVisit.Release do
  @moduledoc """
  Functions for performing tasks from a self-contained release.

  You can invoke the commands below in the release root like this:

      $ bin/home_visit eval "HomeVisit.Release.migrate"
      $ bin/home_visit eval "HomeVisit.Release.rollback(HomeVisit.Api.Repo, 20240418211523)"

  """
  @app :home_visit

  @doc """
  Runs the pending migrations.
  """
  def migrate do
    for repo <- repos(),
        do: {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
  end

  @doc """
  Reverts applied migrations in the given `repo` down to and including the
  specified `version`.
  """
  def rollback(repo, version),
    do: {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))

  defp repos do
    Application.load(@app)
    Application.fetch_env!(@app, :ecto_repos)
  end
end
