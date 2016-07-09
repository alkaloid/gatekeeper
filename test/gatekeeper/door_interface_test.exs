defmodule Gatekeeper.DoorInterfaceTest do
  use ExUnit.Case, async: false
  use Gatekeeper.ModelCase

  import Gatekeeper.Factory

  setup do
    door_group = create_door_group
    door = create_door door_group: door_group
    company = create_company
    member = create_member company: company, door_group: door_group
    rfid_token = create_rfid_token member: member

    doorlock_config = [type: Gatekeeper.DoorLock.Dummy, door_id: door.id, gpio_port: 1]
    rfidreader_config = Application.get_env(:gatekeeper, :rfidreader)
    {:ok, door_interface} = Gatekeeper.DoorInterface.start_link(doorlock_config, rfidreader_config)

    {:ok, door_interface: door_interface, good_token: rfid_token}
  end

  test "opens the door to an scan of a permitted card", %{door_interface: door_interface, good_token: good_token} do
    send(door_interface, {:card_read, good_token.identifier})
    assert Gatekeeper.DoorInterface.state(door_interface) == :unlocked
  end

  test "does not open the door to an scan of an unknown card", %{door_interface: door_interface} do
    send(door_interface, {:card_read, "unknown"})
    assert Gatekeeper.DoorInterface.state(door_interface) == :locked
  end
end
