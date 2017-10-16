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
    door_group = create_door_group()
    door = create_door door_group: door_group
    company = create_company()
    member = create_member company: company

    assert {false, "no_access_to_door"} = Door.member_access_allowed? door, member
  end

  test "member is allowed access if his company has an association with a door group containing the door" do
    door_group = create_door_group()
    door = create_door door_group: door_group
    company = create_company door_group: door_group
    member = create_member company: company

    assert {true, _reason} = Door.member_access_allowed? door, member
  end

  test "member is disallowed access to the door if the door group has no schedule" do
    door_group = create_door_group(skip_default_schedule: true)
    door = create_door door_group: door_group
    company = create_company door_group: door_group
    member = create_member company: company

    # TODO Check reason references no active schedule
    assert {false, _reason} = Door.member_access_allowed? door, member
  end

  test "member is disallowed access to the door group if not in a scheduled period"

  test "member is not allowed access via another's door group schedule"

  test "member is allowed if the time is within the door group schedule"
end
