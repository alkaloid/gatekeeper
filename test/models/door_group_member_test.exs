defmodule Gatekeeper.DoorGroupMemberTest do
  use Gatekeeper.ModelCase

  alias Gatekeeper.DoorGroupMember

  @valid_attrs %{door_group_id: 42, member_id: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = DoorGroupMember.changeset(%DoorGroupMember{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = DoorGroupMember.changeset(%DoorGroupMember{}, @invalid_attrs)
    refute changeset.valid?
  end
end
