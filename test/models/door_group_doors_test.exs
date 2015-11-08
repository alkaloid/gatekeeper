defmodule Gatekeeper.DoorGroupDoorsTest do
  use Gatekeeper.ModelCase

  alias Gatekeeper.DoorGroupDoors

  @valid_attrs %{door_group_id: 42, door_id: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = DoorGroupDoors.changeset(%DoorGroupDoors{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = DoorGroupDoors.changeset(%DoorGroupDoors{}, @invalid_attrs)
    refute changeset.valid?
  end
end
