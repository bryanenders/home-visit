import Config

config :home_visit,
  ecto_repos: [HomeVisit.Api.Repo]

config :home_visit, HomeVisit.Api.Repo,
  database: Path.expand("../home_visit_#{Mix.env()}.db", Path.dirname(__ENV__.file))

config :logger, :console, format: "$time [$level] $message\n"

import_config "#{config_env()}.exs"
