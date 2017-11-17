# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

config :gatekeeper, ecto_repos: [Gatekeeper.Repo, Gatekeeper.WriteRepo]

config :gatekeeper, namespace: Gatekeeper

# Configures the endpoint
config :gatekeeper, GatekeeperWeb.Endpoint,
  url: [host: "localhost"],
  root: Path.dirname(__DIR__),
  secret_key_base: System.get_env("SECRET_KEY_BASE"),
  render_errors: [view: GatekeeperWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Gatekeeper.PubSub,
           adapter: Phoenix.PubSub.PG2]

config :gatekeeper, Gatekeeper.Features,
  automatic_auth: false,
  split_reads: true,
  async_writes: true

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :gatekeeper, :system,
  timezone: "America/New_York"

config :gatekeeper, :rfidreader,
  device: "/dev/ttyUSB0"

config :gatekeeper, :doorlock,
  type: Gatekeeper.GPIODummy,
  gpio_pin: 4,
  duration: 3000, # ms
  door_id: 1

config :gatekeeper, :doorbell,
  gpio_port: String.to_integer(System.get_env("GATEKEEPER_BELL_GPIO") || "17"),
  type: Gatekeeper.GPIODummy

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

# Configure phoenix generators
config :phoenix, :generators,
  migration: true,
  binary_id: false

config :ueberauth, Ueberauth,
  providers: [ slack: { Ueberauth.Strategy.Slack, [team: System.get_env("SLACK_TEAM_ID")] } ]

config :ueberauth, Ueberauth.Strategy.Slack.OAuth,
  client_id: System.get_env("SLACK_CLIENT_ID"),
  client_secret: System.get_env("SLACK_CLIENT_SECRET")

config :guardian, Guardian,
  issuer: "Gatekeeper",
  ttl: { 30, :days },
  verify_issuer: true, # optional
  secret_key: System.get_env("GUARDIAN_SECRET_KEY"),
  serializer: Gatekeeper.GuardianSerializer

config :scrivener_html,
  routes_helper: GatekeeperWeb.Router.Helpers
