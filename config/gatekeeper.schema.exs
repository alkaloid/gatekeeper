@moduledoc """
A schema is a keyword list which represents how to map, transform, and validate
configuration values parsed from the .conf file. The following is an explanation of
each key in the schema definition in order of appearance, and how to use them.

## Import

A list of application names (as atoms), which represent apps to load modules from
which you can then reference in your schema definition. This is how you import your
own custom Validator/Transform modules, or general utility modules for use in
validator/transform functions in the schema. For example, if you have an application
`:foo` which contains a custom Transform module, you would add it to your schema like so:

`[ import: [:foo], ..., transforms: ["myapp.some.setting": MyApp.SomeTransform]]`

## Extends

A list of application names (as atoms), which contain schemas that you want to extend
with this schema. By extending a schema, you effectively re-use definitions in the
extended schema. You may also override definitions from the extended schema by redefining them
in the extending schema. You use `:extends` like so:

`[ extends: [:foo], ... ]`

## Mappings

Mappings define how to interpret settings in the .conf when they are translated to
runtime configuration. They also define how the .conf will be generated, things like
documention, @see references, example values, etc.

See the moduledoc for `Conform.Schema.Mapping` for more details.

## Transforms

Transforms are custom functions which are executed to build the value which will be
stored at the path defined by the key. Transforms have access to the current config
state via the `Conform.Conf` module, and can use that to build complex configuration
from a combination of other config values.

See the moduledoc for `Conform.Schema.Transform` for more details and examples.

## Validators

Validators are simple functions which take two arguments, the value to be validated,
and arguments provided to the validator (used only by custom validators). A validator
checks the value, and returns `:ok` if it is valid, `{:warn, message}` if it is valid,
but should be brought to the users attention, or `{:error, message}` if it is invalid.

See the moduledoc for `Conform.Schema.Validator` for more details and examples.
"""
[
  extends: [],
  import: [],
  mappings: [
    "gatekeeper.rfidreader.device": [
      commented: false,
      datatype: :binary,
      default: "/dev/ttyUSB0",
      doc: "Path to device file for RFID reader",
      hidden: false,
      to: "gatekeeper.rfidreader.device"
    ],
    "gatekeeper.doorlock.type": [
      commented: false,
      datatype: :binary,
      default: "gpio",
      doc: "Module name representing the driver for the Door Lock",
      hidden: true,
      to: "gatekeeper.doorlock.type"
    ],
    "gatekeeper.doorlock.gpio_pin": [
      commented: false,
      datatype: :integer,
      default: 4,
      doc: "GPIO pin for signaling the door strike to unlock",
      hidden: false,
      to: "gatekeeper.doorlock.gpio_pin"
    ],
    "gatekeeper.doorlock.duration": [
      commented: false,
      datatype: :integer,
      default: 3000,
      doc: "How long (in milliseconds) to keep the door unlocked after reading a badge",
      hidden: false,
      to: "gatekeeper.doorlock.duration"
    ],
    "gatekeeper.doorlock.door_id": [
      commented: false,
      datatype: :integer,
      default: 1,
      doc: "ID of the door controlled by this instance of Gatekeeper",
      hidden: false,
      to: "gatekeeper.doorlock.door_id"
    ],
    "gatekeeper.doorbell.type": [
      commented: false,
      datatype: :binary,
      default: "gpio",
      doc: "Module name representing the driver for the Door Bell",
      hidden: true,
      to: "gatekeeper.doorbell.type"
    ],
    "gatekeeper.doorbell.gpio_pin": [
      commented: false,
      datatype: :integer,
      default: 17,
      doc: "GPIO pin for signaling that the door bell has been rung",
      hidden: false,
      to: "gatekeeper.doorbell.gpio_pin"
    ],
    "gatekeeper.Elixir.GatekeeperWeb.Endpoint.url.host": [
      commented: false,
      datatype: :binary,
      default: "localhost",
      doc: "Domain name at which application is running, for web server to generate links",
      hidden: false,
      to: "gatekeeper.Elixir.GatekeeperWeb.Endpoint.url.host"
    ],
    "gatekeeper.Elixir.GatekeeperWeb.Endpoint.root": [
      commented: false,
      datatype: :binary,
      default: Path.dirname(__DIR__),
      doc: "Base directory for Gatekeeper application",
      hidden: false,
      to: "gatekeeper.Elixir.GatekeeperWeb.Endpoint.root"
    ],
    "gatekeeper.Elixir.GatekeeperWeb.Endpoint.secret_key_base": [
      commented: false,
      datatype: :binary,
      doc: "Secret key used for securing session cookies",
      hidden: false,
      env_var: "SECRET_KEY_BASE",
      to: "gatekeeper.Elixir.GatekeeperWeb.Endpoint.secret_key_base"
    ],
    "gatekeeper.Elixir.GatekeeperWeb.Endpoint.http.port": [
      commented: false,
      datatype: :integer,
      default: 4000,
      doc: "Port on which application listens for HTTP connections",
      hidden: false,
      to: "gatekeeper.Elixir.GatekeeperWeb.Endpoint.http.port"
    ],
    "gatekeeper.Elixir.Gatekeeper.Repo.username": [
      commented: false,
      datatype: :binary,
      default: "gatekeeper",
      doc: "Database username for the READ ONLY connection",
      hidden: false,
      env_var: "DATABASE_READ_USERNAME",
      to: "gatekeeper.Elixir.Gatekeeper.Repo.username"
    ],
    "gatekeeper.Elixir.Gatekeeper.Repo.password": [
      commented: false,
      datatype: :binary,
      default: "gatekeeper",
      doc: "Database password for the READ ONLY connection",
      hidden: false,
      env_var: "DATABASE_READ_PASSWORD",
      to: "gatekeeper.Elixir.Gatekeeper.Repo.password"
    ],
    "gatekeeper.Elixir.Gatekeeper.Repo.database": [
      commented: false,
      datatype: :binary,
      default: "gatekeeper_dev",
      doc: "Database name for the READ ONLY connection",
      hidden: false,
      env_var: "DATABASE_READ_DATABASE",
      to: "gatekeeper.Elixir.Gatekeeper.Repo.database"
    ],
    "gatekeeper.Elixir.Gatekeeper.Repo.hostname": [
      commented: false,
      datatype: :binary,
      default: "localhost",
      doc: "Database hostname for the READ ONLY connection",
      hidden: false,
      env_var: "DATABASE_READ_HOSTNAME",
      to: "gatekeeper.Elixir.Gatekeeper.Repo.hostname"
    ],
    "gatekeeper.Elixir.Gatekeeper.Repo.template": [
      commented: false,
      datatype: :binary,
      default: "template0",
      doc: "Postgresql template for the READ ONLY connection",
      hidden: true,
      to: "gatekeeper.Elixir.Gatekeeper.Repo.template"
    ],
    "gatekeeper.Elixir.Gatekeeper.Repo.pool_size": [
      commented: false,
      datatype: :integer,
      default: 10,
      doc: "Number of database connections available in the pool for the READ ONLY connection",
      hidden: false,
      to: "gatekeeper.Elixir.Gatekeeper.Repo.pool_size"
    ],
    "gatekeeper.Elixir.Gatekeeper.WriteRepo.username": [
      commented: false,
      datatype: :binary,
      default: "gatekeeper",
      doc: "Database username for the WRITABLE connection",
      hidden: false,
      env_var: "DATABASE_WRITE_USERNAME",
      to: "gatekeeper.Elixir.Gatekeeper.WriteRepo.username"
    ],
    "gatekeeper.Elixir.Gatekeeper.WriteRepo.password": [
      commented: false,
      datatype: :binary,
      default: "gatekeeper",
      doc: "Database password for the WRITABLE connection",
      hidden: false,
      env_var: "DATABASE_WRITE_PASSWORD",
      to: "gatekeeper.Elixir.Gatekeeper.WriteRepo.password"
    ],
    "gatekeeper.Elixir.Gatekeeper.WriteRepo.database": [
      commented: false,
      datatype: :binary,
      default: "gatekeeper_dev",
      doc: "Database name for the WRITABLE connection",
      hidden: false,
      env_var: "DATABASE_WRITE_DATABASE",
      to: "gatekeeper.Elixir.Gatekeeper.WriteRepo.database"
    ],
    "gatekeeper.Elixir.Gatekeeper.WriteRepo.hostname": [
      commented: false,
      datatype: :binary,
      default: "localhost",
      doc: "Database hostname for the WRITABLE connection",
      hidden: false,
      env_var: "DATABASE_WRITE_HOSTNAME",
      to: "gatekeeper.Elixir.Gatekeeper.WriteRepo.hostname"
    ],
    "gatekeeper.Elixir.Gatekeeper.WriteRepo.template": [
      commented: false,
      datatype: :binary,
      default: "template0",
      doc: "Postgresql template for the WRITABLE connection",
      hidden: true,
      to: "gatekeeper.Elixir.Gatekeeper.WriteRepo.template"
    ],
    "gatekeeper.Elixir.Gatekeeper.WriteRepo.pool_size": [
      commented: false,
      datatype: :integer,
      default: 10,
      doc: "Number of database connections available in the pool for the WRITABLE connection",
      hidden: false,
      to: "gatekeeper.Elixir.Gatekeeper.WriteRepo.pool_size"
    ],
    "ueberauth.Elixir.Ueberauth.providers.slack": [
      commented: false,
      datatype: :binary,
      doc: "Team ID for Slack authentication",
      hidden: false,
      env_var: "SLACK_TEAM_ID",
      to: "ueberauth.Elixir.Ueberauth.providers.slack"
    ],
    "ueberauth.Elixir.Ueberauth.Strategy.Slack.OAuth.client_id": [
      commented: false,
      datatype: :binary,
      default: "",
      doc: "Slack OAuth Client ID",
      hidden: false,
      env_var: "SLACK_CLIENT_ID",
      to: "ueberauth.Elixir.Ueberauth.Strategy.Slack.OAuth.client_id"
    ],
    "ueberauth.Elixir.Ueberauth.Strategy.Slack.OAuth.client_secret": [
      commented: false,
      datatype: :binary,
      default: "",
      doc: "Slack OAuth Client Secret",
      hidden: false,
      env_var: "SLACK_CLIENT_SECRET",
      to: "ueberauth.Elixir.Ueberauth.Strategy.Slack.OAuth.client_secret"
    ],
    "guardian.Elixir.Guardian.ttl": [
      commented: false,
      datatype: {:integer, :atom},
      default: {30, :days},
      doc: "Web session duration",
      hidden: false,
      to: "guardian.Elixir.Guardian.ttl"
    ],
    "guardian.Elixir.Guardian.secret_key": [
      commented: false,
      datatype: :binary,
      default: "",
      doc: "Secret key to sign/secure session cookies",
      hidden: false,
      env_var: "GUARDIAN_SECRET_KEY",
      to: "guardian.Elixir.Guardian.secret_key"
    ],
  ],
  transforms: [
    "ueberauth.Elixir.Ueberauth.providers.slack": fn conf ->
      [{_, team_id}] = Conform.Conf.get(conf, "ueberauth.Elixir.Ueberauth.providers.slack")
      {Ueberauth.Strategy.Slack, [team: team_id]}
    end,
    "gatekeeper.doorlock.type": fn conf ->
      [{_, type}] = Conform.Conf.get(conf, "gatekeeper.doorlock.type")
      case type do
        "gpio" -> ElixirALE.GPIO
        "dummy" -> Gatekeeper.GPIODummy
      end
    end,
    "gatekeeper.doorbell.type": fn conf ->
      [{_, type}] = Conform.Conf.get(conf, "gatekeeper.doorbell.type")
      case type do
        "gpio" -> ElixirALE.GPIO
        "dummy" -> Gatekeeper.GPIODummy
      end
    end
  ],
  validators: []
]
