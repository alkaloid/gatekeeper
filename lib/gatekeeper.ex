defmodule Gatekeeper do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    doorlock_config = Application.get_env(:gatekeeper, :doorlock)
    doorbell_config = Application.get_env(:gatekeeper, :doorbell)
    rfidreader_config = Application.get_env(:gatekeeper, :rfidreader)

    children = [
      # Start the endpoint when the application starts
      supervisor(Gatekeeper.Endpoint, []),
      # Start the Ecto repositories
      worker(Gatekeeper.Repo, []), # local, read-only
      worker(Gatekeeper.WriteRepo, []), # remote, read-write
      worker(Gatekeeper.WriteRepoWrapper, []), # wrapper to allow writes to fail
      # Here you could define other workers and supervisors as children
      worker(Gatekeeper.DoorBell, [doorbell_config[:gpio_port], doorbell_config[:type]]),
      worker(Gatekeeper.DoorInterface, [{
          doorlock_config[:type],
          doorlock_config[:gpio_pin],
          doorlock_config[:door_id],
          doorlock_config[:duration],
          rfidreader_config[:device]
        }]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Gatekeeper.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Gatekeeper.Endpoint.config_change(changed, removed)
    :ok
  end
end

