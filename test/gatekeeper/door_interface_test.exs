defmodule Gatekeeper.DoorInterfaceTest do
  use ExUnit.Case, async: false
  use Gatekeeper.ModelCase

  import Gatekeeper.Factory

  setup do
    company = create_company
    door_group = create_door_group
    door = create_door door_group: door_group
    member = create_member company: company, door_group: door_group
    rfid_token = create_rfid_token member: member

    {:ok, door} = Gatekeeper.DoorInterface.start_link(door.id)
    {:ok, door_interface: door, good_token: rfid_token}
  end

  test "opens the door to an scan of a permitted card", %{door_interface: door_interface, good_token: good_token} do
    send(door_interface, {:card_read, good_token.identifier})
    assert Gatekeeper.DoorInterface.state(door_interface) == :unlocked
  end

  test "does not open the door to an scan of an unknown card", %{door_interface: door_interface, good_token: good_token} do
    send(door_interface, {:card_read, "7A0092D11F26"})
    assert Gatekeeper.DoorInterface.state(door_interface) == :locked
  end
end