defmodule Gatekeeper.DoorLock do
  require Logger

  use GenServer

  def start_link(door_id, gpio_number, type \\ Gatekeeper.DoorLock.Dummy, opts \\ []) do
    GenServer.start_link(__MODULE__, [door_id, gpio_number, type], opts)
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

  def init([door_id, gpio_number, type]) do
    {:ok, gpio} = type.start_link(door_id, gpio_number, :output)
    type.write(gpio, 0)

    Logger.info "Door Lock process started on GPIO##{gpio_number} with GPIO PID #{inspect gpio}"

    {:ok, {type, gpio, door_id}}
  end

  def handle_call(:getstate, _from, {type, gpio, door_id} = state) do
    lockstate = case type.read(gpio) do
      0 -> :locked
      1 -> :unlocked
    end
    {:reply, lockstate, state}
  end

  def handle_call(:lock, _from, {type, gpio, door_id} = state) do
    Logger.info "Locking the door"
    type.write(gpio, 0)
    {:reply, :ok, state}
  end

  def handle_call(:unlock, _from, {type, gpio, door_id} = state) do
    Logger.info "Unlocking the door"
    type.write(gpio, 1)
    {:reply, :ok, state}
  end

  def handle_call({:flipflop, duration}, _from, {type, gpio, door_id} = state) do
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

defmodule Gatekeeper.DoorLock.Dummy do
  use GenServer

  def start_link(_door_id, _gpio_number, _type, opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    {:ok, 1}
  end

  def write(pid, value) do
    GenServer.call(pid, {:write, value})
  end

  def read(pid) do
    GenServer.call(pid, :read)
  end

  def handle_call({:write, value}, _from, _state) do
    {:reply, :ok, value}
  end

  def handle_call(:read, _from, state) do
    {:reply, state, state}
  end
end
