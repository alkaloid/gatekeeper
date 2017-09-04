defmodule Gatekeeper.DoorLockStatusPlug do
  alias Gatekeeper.Repo
  alias Gatekeeper.Door
  alias Gatekeeper.DoorLock

  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    doors = Repo.all(Door)
    door_statuses = Enum.reduce(doors, %{}, fn(door, door_statuses) ->
      Dict.merge(door_statuses, case DoorLock.pidof(door.id) do
        :undefined ->
          %{door.id => :unknown}
        pid ->
          %{door.id => DoorLock.state(pid)}
      end)
    end)
    conn
    |> assign(:doors, doors)
    |> assign(:door_statuses, door_statuses)
  end

  def color_and_icon(status) do
    case status do
      :unknown ->
        ["warning", "question-circle"]
      :locked ->
        ["info", "lock"]
      :unlocked ->
        ["danger", "unlock"]
    end
  end
end

