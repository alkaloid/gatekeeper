use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :gatekeeper, GatekeeperWeb.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  cache_static_lookup: false,
  check_origin: false,
  watchers: [node: ["node_modules/brunch/bin/brunch", "watch", "--stdin",
                    cd: Path.expand("../assets", __DIR__)]]

# Watch static and templates for browser reloading.
config :gatekeeper, GatekeeperWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{lib/gatekeeper_web/views/.*(ex)$},
      ~r{lib/gatekeeper_web/templates/.*(eex)$}
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development.
# Do not configure such in production as keeping
# and calculating stacktraces is usually expensive.
config :phoenix, :stacktrace_depth, 20

# Configure your database
config :gatekeeper, Gatekeeper.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("DATABASE_READ_USERNAME") || "gatekeeper",
  password: System.get_env("DATABASE_READ_PASSWORD") || "gatekeeper",
  database: System.get_env("DATABASE_READ_DATABASE") || "gatekeeper_dev",
  hostname: System.get_env("DATABASE_WRITE_HOSTNAME") || "localhost",
  template: "template0",
  pool_size: 10

config :gatekeeper, Gatekeeper.WriteRepo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("DATABASE_WRITE_USERNAME" || "gatekeeper"),
  password: System.get_env("DATABASE_WRITE_PASSWORD" || "gatekeeper"),
  database: System.get_env("DATABASE_WRITE_DATABASE" || "gatekeeper_dev"),
  hostname: System.get_env("DATABASE_WRITE_HOSTNAME") || "localhost",
  template: "template0",
  pool_size: 10
