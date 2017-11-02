defmodule Gatekeeper.DoorLock do
  require Logger

  use GenServer

  def start_link(type, gpio_pin, door_id, opts \\ []) do
    default_opts = [name: {:global, proc_name(door_id)}]
    opts = Keyword.merge(default_opts, opts)
    GenServer.start_link(__MODULE__, [door_id, gpio_pin, type], opts)
  end

  def pidof(id) do
    proc_name(id) |> :global.whereis_name
  end

  def proc_name(id) do
    String.to_atom("door_lock_#{id}")
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

  def init([door_id, gpio_pin, type]) do
    {:ok, gpio} = type.start_link(gpio_pin, :output)
    type.write(gpio, 0)

    door = case Gatekeeper.Repo.get(Gatekeeper.Door, door_id) do
      %Gatekeeper.Door{} = door ->
        door
      nil ->
        %Gatekeeper.Door{name: 'Unknown Door'}
    end

    Logger.info "Door Lock process started for #{door.name} (##{door_id}) on GPIO##{gpio_pin} with PID #{inspect gpio}"

    {:ok, {type, gpio, door_id, door}}
  end

  def handle_call(:getstate, _from, {type, gpio, _door_id, _door} = state) do
    lockstate = case type.read(gpio) do
      0 -> :locked
      1 -> :unlocked
    end
    {:reply, lockstate, state}
  end

  def handle_call(:lock, _from, {type, gpio, door_id, door} = state) do
    Logger.info "Locking door #{door.name} (##{door_id})"
    GatekeeperWeb.Endpoint.broadcast! "door_lock:#{door_id}", "status_change", %{status: :locked}
    type.write(gpio, 0)
    {:reply, :ok, state}
  end

  def handle_call(:unlock, _from, {type, gpio, door_id, door} = state) do
    Logger.info "Unlocking door #{door.name} (##{door_id})"
    GatekeeperWeb.Endpoint.broadcast! "door_lock:#{door_id}", "status_change", %{status: :unlocked}
    type.write(gpio, 1)
    {:reply, :ok, state}
  end

  def handle_call({:flipflop, duration}, _from, {type, gpio, door_id, door} = state) do
    Logger.info "Unlocking door #{door.name} (##{door_id}) for #{duration}ms"
    GatekeeperWeb.Endpoint.broadcast! "door_lock:#{door_id}", "status_change", %{status: :unlocked}
    server = self()
    type.write(gpio, 1)
    Task.start_link(fn ->
      :timer.sleep(duration)
      Gatekeeper.DoorLock.lock(server)
    end)
    {:reply, :ok, state}
  end
end

defmodule Gatekeeper.DoorLock.Dummy do
  use GenServer

  def start_link(_gpio_pin, _type, opts \\ []) do
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
