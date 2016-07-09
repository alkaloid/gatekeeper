defmodule Gatekeeper.DoorInterface do
  require Logger
  use GenServer

  def start_link( doorlock_config = [type: type, gpio_pin: gpio_pin, door_id: door_id], rfidreader_config = [device: device], opts \\ []) do
    GenServer.start_link(__MODULE__, [doorlock_config, rfidreader_config], opts)
  end

  @doc """
    Provides the state of the lock
  """
  @spec state(pid()) :: atom()
  def state(pid) do
    GenServer.call(pid, :getstate)
  end

  def init(doorlock_config, rfidreader_config) do
    {:ok, rfid} = Gatekeeper.RFIDListener.start_link(rfidreader_config[:device])

    lock = case Gatekeeper.DoorLock.start_link(
      doorlock_config[:door_id],
      doorlock_config[:gpio_pin],
      doorlock_config[:type]
      ) do
      {:ok, lock} ->
        lock
      {:error, {:already_started, lock}} ->
        lock
    end

    {:ok, {rfid, lock, doorlock_config[:door_id]}}
  end

  def handle_call(:getstate, _from, {_rfid, lock, _door_id} = state) do
    lockstate = Gatekeeper.DoorLock.state(lock)
    {:reply, lockstate, state}
  end

  def handle_info({:card_read, token}, {_rfid, lock, door_id} = state) do
    case Gatekeeper.RfidToken.attempt_access!(token, door_id) do
      {true, _} ->
        Logger.info("Card #{token} granted access to Door##{door_id}. Unlocking the door.")
        Gatekeeper.DoorLock.flipflop(lock)
      {false, reason} ->
        Logger.info("Card #{token} denied access to Door##{door_id}: #{reason}.")
    end
    {:noreply, state}
  end
end
