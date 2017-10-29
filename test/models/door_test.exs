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
    door = create_door door_group: create_door_group()
    company = create_company(door_group: create_door_group())
    member = create_member(company: company)

    assert {false, "no_access_to_door"} = Door.member_access_allowed? door, member
  end

  test "member is allowed access if his company has an association with a door group containing the door" do
    door_group = create_door_group()
    door = create_door door_group: door_group
    company = create_company door_group: door_group
    member = create_member company: company

    assert {true, "access_allowed"} = Door.member_access_allowed? door, member
  end

  test "member is disallowed access to the door if the door group has no schedule" do
    door_group = create_door_group(skip_default_schedule: true)
    door = create_door door_group: door_group
    company = create_company door_group: door_group
    member = create_member company: company

    assert {false, "outside_hours"} = Door.member_access_allowed? door, member
  end

  test "member is disallowed access to the door group if not in a scheduled period" do
    {:ok, test_time} = Timex.parse("2017-04-13T12:30:00-04:00", "{ISO:Extended}")

    door_group = create_door_group(skip_default_schedule: true)

    {:ok, day_of_week} = Timex.format(test_time, "%A", :strftime)
    start_time = ~T[00:00:00.000000]
    end_time = ~T[12:00:00.000000]
    create_door_group_schedule(door_group: door_group, day_of_week: day_of_week, start_time: start_time, end_time: end_time)

    start_time = ~T[13:00:00.000000]
    end_time = ~T[23:59:59.999999]
    create_door_group_schedule(door_group: door_group, day_of_week: day_of_week, start_time: start_time, end_time: end_time)

    door = create_door door_group: door_group
    company = create_company door_group: door_group
    member = create_member company: company

    assert {false, "outside_hours"} = Door.member_access_allowed? door, member, test_time
  end

  test "member is not allowed access via another's door group schedule" do
    {:ok, test_time} = Timex.parse("2017-04-13T12:30:00-04:00", "{ISO:Extended}")

    _door_group1 = create_door_group()
    door_group2 = create_door_group(skip_default_schedule: true)

    door = create_door door_group: door_group2
    company = create_company door_group: door_group2
    member = create_member company: company

    assert {false, "outside_hours"} = Door.member_access_allowed? door, member, test_time
  end

  test "member is allowed if the time is within the door group schedule" do
    {:ok, test_time} = Timex.parse("2017-04-13T12:30:00-04:00", "{ISO:Extended}")

    door_group = create_door_group(skip_default_schedule: true)

    {:ok, day_of_week} = Timex.format(test_time, "%A", :strftime)
    start_time = ~T[12:00:00.000000]
    end_time = ~T[13:59:59.999999]
    create_door_group_schedule(door_group: door_group, day_of_week: day_of_week, start_time: start_time, end_time: end_time)

    door = create_door door_group: door_group
    company = create_company door_group: door_group
    member = create_member company: company

    assert {true, "access_allowed"} = Door.member_access_allowed? door, member, test_time
  end
end
