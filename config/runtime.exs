import Config

if config_env() === :prod do
  database_path =
    System.get_env("DATABASE_PATH") ||
      raise """
      DATABASE_PATH environment variable is missing.
      For example: /data/name/name.db
      """

  config :home_visit, HomeVisit.Api.Repo,
    database: database_path,
    pool_size:
      "POOL_SIZE"
      |> System.get_env("10")
      |> String.to_integer()
end
