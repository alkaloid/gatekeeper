defmodule Gatekeeper.DoorInterface do
  require Logger

  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    {:ok, rfid} = Gatekeeper.RFIDListener.start_link(
      Application.get_env(:gatekeeper, :rfidreader)[:device]
    )

    doorlock_config = Application.get_env(:gatekeeper, :doorlock)
    {:ok, lock} = Gatekeeper.DoorLock.start_link(
      doorlock_config[:gpio_port], doorlock_config[:type]
    )

    {:ok, {rfid, lock}}
  end

  def handle_info({:card_read, token}, {_rfid, lock} = state) do
    if Gatekeeper.RfidToken.access_permitted?(token) do
      Logger.info("Card #{token} requested access. Unlocking the door.")
      Gatekeeper.DoorLock.flipflop(lock)
    else
      Logger.info("Card #{token} requested access. Access was denied.")
    end
    {:noreply, state}
  end
end
