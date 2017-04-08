defmodule Gatekeeper.DoorBell do
  require Logger

  use GenServer
  use Timex

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

    {:ok, %{gpio_number: gpio_number, type: type, gpio_pid: pid, last_signal: Timex.now()}}
  end

  def handle_call(request, from, state) do
    Logger.error "Received Call #{inspect request} - from #{inspect from} - state #{inspect state}"
    {:reply, :ok, state}
  end

  def handle_cast(request, from, state) do
    Logger.error "Received Cast #{inspect request} - from #{inspect from} - state #{inspect state}"
    {:noreply, state}
  end

  def handle_info({:gpio_interrupt, _gpio_port, :falling}, state = %{last_signal: last_signal}) do
    {_, seconds, ms} = Timex.diff(Timex.now, last_signal)
    state = if seconds < 2 do
      Logger.debug "Ignoring bounce on GPIO; last signal was #{seconds}.#{ms} seconds ago"
      state
    else
      notify()
      Map.put(state, :last_signal, Timex.now)
    end
    {:noreply, state}
  end
  def handle_info(msg, state) do
    Logger.debug "Received Info msg - #{inspect msg} - state #{inspect state}"
    {:noreply, state}
  end

  def notify() do
    Logger.info "Ding dong! Notifying..."
    door_id = Application.get_env(:gatekeeper, :doorlock)[:door_id]
    {:ok, _response} = HTTPoison.post @notify_url, {:form, [{"door_id", "#{door_id}"}]}
  end
end

