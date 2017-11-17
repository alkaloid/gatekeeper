use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :gatekeeper, GatekeeperWeb.Endpoint,
  http: [port: 4001],
  secret_key_base: "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
  server: false

config :gatekeeper, Gatekeeper.Features,
  split_reads: false,
  async_writes: false

# Print only warnings and errors during test
config :logger, level: :debug

config :ex_unit, capture_log: true

# Configure your database
config :gatekeeper, Gatekeeper.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "gatekeeper_test",
  hostname: "localhost",
  template: "template0",
  pool: Ecto.Adapters.SQL.Sandbox

config :gatekeeper, Gatekeeper.WriteRepo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "gatekeeper_test",
  hostname: "localhost",
  template: "template0",
  pool: Ecto.Adapters.SQL.Sandbox

System.put_env("GUARDIAN_SECRET_KEY", "abcd")
