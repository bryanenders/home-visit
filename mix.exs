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
      docs: [
        main: "readme",
        extras: ["README.md"],
        source_url: "https://github.com/bryanenders/home-visit"
      ],
      elixir: "~> 1.16",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() === :prod,
      version: "0.1.0"
    ]
  end

  defp deps do
    [
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:ecto_sqlite3, "~> 0.15"},
      {:ex_doc, "~> 0.31", only: :dev, runtime: false}
    ]
  end

  defp elixirc_paths(:test),
    do: ["lib", "test/support"]

  defp elixirc_paths(_),
    do: ["lib"]
end
