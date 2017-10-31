defmodule Gatekeeper.Mixfile do
  use Mix.Project

  def project do
    [app: :gatekeeper,
     version: "0.0.1",
     elixir: "~> 1.0",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases(),
     deps: deps()]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {Gatekeeper.Application, []},
     applications: [
       :cowboy,
       :gettext,
       :logger,
       :phoenix,
       :phoenix_pubsub,
       :phoenix_ecto,
       :postgrex,
       :phoenix_html,
       :scrivener_ecto,
       :tzdata,
       :ueberauth,
       :ueberauth_slack
     ]
   ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:conform, "~> 2.2"},
      {:cowboy, "~> 1.0"},
      {:distillery, "~> 1.5", runtime: false},
      {:elixir_ale, "~> 1.0.0", only: :prod},
      {:gettext, "~> 0.9"},
      {:guardian, "~> 0.14.2"},
      {:mix_test_watch, "~> 0.2", only: :dev},
      {:oauth2, "0.6.0"},
      {:phoenix, "~> 1.3.0"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_ecto, "~> 3.0-rc"},
      {:phoenix_html, "~> 2.6"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:postgrex, ">= 0.0.0"},
      {:serial, "0.1.1"},
      {:scrivener, "~> 2.0"},
      {:scrivener_ecto, "~> 1.0"},
      {:scrivener_html, "~> 1.1"},
      {:timex, git: "https://github.com/bitwalker/timex.git", branch: "master"},
      {:ueberauth, "~> 0.4"},
      {:ueberauth_slack, "~> 0.4"},
    ]
  end

  # Aliases are shortcut or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    ["ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
     "ecto.reset": ["ecto.drop", "ecto.setup"],
     "test": ["ecto.create --quiet", "ecto.migrate", "test"]
   ]
  end
end
