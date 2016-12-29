defmodule Gatekeeper.DoorBell do
  require Logger

  use GenServer

  @notify_url "http://10.3.18.99:4000/api/door_bell"

  def start_link(gpio_number, type \\ Gatekeeper.GpioDummy, opts \\ []) do
    opts = Dict.merge(opts, name: __MODULE__)
    GenServer.start_link(__MODULE__, [gpio_number, type], opts)
  end

  def server do
    Process.whereis(__MODULE__) ||
      raise "could not find process #{__MODULE__}. Have you started the application?"
  end

  def init([gpio_number, type]) do
    Logger.info "Starting door bell watcher on GPIO pin #{gpio_number}"
    pid = if type == Gpio do
      System.cmd("/usr/bin/gpio", ["-g", "mode", "#{gpio_number}", "in"])
      System.cmd("/usr/bin/gpio", ["-g", "mode", "#{gpio_number}", "up"])
      {:ok, pid} = Gpio.start_link(gpio_number, :input)
      Gpio.set_int(pid, :rising)
      pid
    else
      nil
    end

    {:ok, %{gpio_number: gpio_number, type: type, gpio_pid: pid}}
  end

  def handle_call(request, from, state) do
    Logger.error "Received Call #{inspect request} - from #{inspect from} - state #{inspect state}"
    {:reply, :ok, state}
  end

  def handle_cast(request, from, state) do
    Logger.error "Received Cast #{inspect request} - from #{inspect from} - state #{inspect state}"
    {:noreply, state}
  end

  def handle_info({:gpio_interrupt, _gpio_port, :falling}, state) do
    Logger.info "Ding dong! Notifying..."
    door_id = Application.get_env(:gatekeeper, :door_lock)[:door_id]
    {:ok, _response} = HTTPoison.post @notify_url, {:multipart, [{"door_id", "#{door_id}"}]}
    {:noreply, state}
  end
  def handle_info(msg, state) do
    Logger.debug "Received Info msg - #{inspect msg} - state #{inspect state}"
    {:noreply, state}
  end
end

