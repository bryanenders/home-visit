defmodule HomeVisit.MixProject do
  use Mix.Project

  def application do
    [
      extra_applications: [:logger],
      mod: {HomeVisit.Application, []}
    ]
  end

  def project do
    [
      app: :home_visit,
      deps: deps(),
      elixir: "~> 1.16",
      start_permanent: Mix.env() === :prod,
      version: "0.1.0"
    ]
  end

  defp deps do
    [
      {:ecto_sqlite3, "~> 0.15"}
    ]
  end
end
