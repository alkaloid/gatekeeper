defmodule Gatekeeper.DoorGroupDoorTest do
  use Gatekeeper.ModelCase

  alias Gatekeeper.DoorGroupDoor

  @valid_attrs %{door_group_id: 42, door_id: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = DoorGroupDoor.changeset(%DoorGroupDoor{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = DoorGroupDoor.changeset(%DoorGroupDoor{}, @invalid_attrs)
    refute changeset.valid?
  end
end
