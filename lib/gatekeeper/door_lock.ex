defmodule Gatekeeper.DoorLock do
  require Logger

  use GenServer

  def start_link(gpio_number, type \\ Gatekeeper.GpioDummy, opts \\ []) do
    GenServer.start_link(__MODULE__, [gpio_number, type], opts)
  end

  @doc """
    Provides the state of the lock
  """
  @spec state(pid()) :: atom()
  def state(pid) do
    GenServer.call(pid, :getstate)
  end

  @doc """
    Locks the door and maintains it locked
  """
  def lock(pid) do
    GenServer.call(pid, :lock)
  end

  @doc """
    Unlocks the door and maintains it unlocked
  """
  def unlock(pid) do
    GenServer.call(pid, :unlock)
  end

  @doc """
    Unlocks the door for long enough to open it, then locks it again
  """
  def flipflop(pid, duration \\ 5000) do
    GenServer.call(pid, {:flipflop, duration})
  end

  def init([gpio_number, type]) do
    {:ok, gpio} = type.start_link(gpio_number, :output)
    type.write(gpio, 0)

    Logger.info "Door Lock process started on GPIO##{gpio_number} with GPIO PID #{inspect gpio}"

    {:ok, {type, gpio}}
  end

  def handle_call(:getstate, _from, {type, gpio} = state) do
    lockstate = case type.read(gpio) do
      0 -> :locked
      1 -> :unlocked
    end
    {:reply, lockstate, state}
  end

  def handle_call(:lock, _from, {type, gpio} = state) do
    Logger.info "Locking the door"
    type.write(gpio, 0)
    {:reply, :ok, state}
  end

  def handle_call(:unlock, _from, {type, gpio} = state) do
    Logger.info "Unlocking the door"
    type.write(gpio, 1)
    {:reply, :ok, state}
  end

  def handle_call({:flipflop, duration}, _from, {type, gpio} = state) do
    Logger.info "Flipflopping the door"
    server = self()
    type.write(gpio, 1)
    Task.async(fn ->
      :timer.sleep(duration)
      Gatekeeper.DoorLock.lock(server)
    end)
    {:reply, :ok, state}
  end
end

