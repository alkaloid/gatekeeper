defmodule GatekeeperWeb.DoorLockChannel do
  require Logger
  use Phoenix.Channel

  alias Gatekeeper.DoorLock
  alias Gatekeeper.Door
  alias Gatekeeper.Repo

  def join("door_lock:" <> door_id, _message, socket) do
    send(self(), :after_join)
    socket = assign(socket, :door_id, door_id)
    {:ok, socket}
  end

  def handle_info(:after_join, socket) do
    door = Repo.get(Door, socket.assigns[:door_id])
    status = case DoorLock.pidof(door.id) do
      :undefined ->
        :unknown
      pid ->
        DoorLock.state(pid)
    end
    push socket, "status_change", %{status: status}
    {:noreply, socket}
  end
end
