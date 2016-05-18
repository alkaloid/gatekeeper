defmodule Gatekeeper.DoorTest do
  use Gatekeeper.ModelCase
  use Gatekeeper.WriteRepo # allow for hacky override of WriteRepo for tests

  import Gatekeeper.Factory

  alias Gatekeeper.Door

  @valid_attrs %{name: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Door.changeset(%Door{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Door.changeset(%Door{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "member is disallowed access if he does not have any association with a door group containing the door" do
    door_group = create_door_group
    door = create_door door_group: door_group
    company = create_company
    member = create_member company: company

    assert {false, "no_access_to_door"} = Door.member_access_allowed? door, member
  end

  test "member is allowed access if he has an association with a door group containing the door" do
    door_group = create_door_group
    door = create_door door_group: door_group
    company = create_company
    member = create_member company: company, door_group: door_group

    assert {true, _reason} = Door.member_access_allowed? door, member
  end

  test "member is allowed access if his company has an association with a door group containing the door" do
    door_group = create_door_group
    door = create_door door_group: door_group
    company = create_company door_group: door_group
    member = create_member company: company

    assert {true, _reason} = Door.member_access_allowed? door, member
  end
end
