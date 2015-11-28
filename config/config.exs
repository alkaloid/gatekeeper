# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :gatekeeper, Gatekeeper.Endpoint,
  url: [host: "localhost"],
  root: Path.dirname(__DIR__),
  secret_key_base: "dnF75HX8VxTVZJhe19bUwhdqgkTWLxgXT2YbD0O6RXCadho2reGj83sLycjoO7MI",
  render_errors: [accepts: ~w(html json)],
  pubsub: [name: Gatekeeper.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :gatekeeper, :rfidreader,
  device: "/dev/ttyUSB0"

config :gatekeeper, :doorlock,
  gpio_port: '2',
  type: Gatekeeper.DoorLock.Dummy

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
