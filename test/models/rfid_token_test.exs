defmodule Gatekeeper.RfidTokenTest do
  use Gatekeeper.ModelCase
  import Gatekeeper.Factory

  alias Gatekeeper.Company
  alias Gatekeeper.Member
  alias Gatekeeper.RfidToken
  alias Gatekeeper.Repo
  alias Gatekeeper.DoorAccessAttempt

  @valid_attrs %{identifier: "some content", active: false, member_id: 1}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = RfidToken.changeset(%RfidToken{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = RfidToken.changeset(%RfidToken{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "checks whether an RFID token permits access when it should" do
    m = %RfidToken{active: true, member: create_member(company: create_company)}
    assert RfidToken.active?(m)
  end

  test "checking for an inactive RFID token" do
    m = %RfidToken{active: false, member: create_member(company: create_company)}
    refute RfidToken.active?(m)
  end

  test "checking for an inactive member" do
    m = %RfidToken{active: true, member: create_member(active: false, company: create_company)}
    refute RfidToken.active?(m)
  end

  test "checking for an inactive company" do
    m = %RfidToken{active: true, member: create_member(company: create_company(departure_date: "2015-04-30 00:00:00"))}
    refute RfidToken.active?(m)
  end

  test "checking that the door should be allowed to open" do
    company = create_company
    door_group = create_door_group
    door = create_door door_group: door_group
    member = create_member company: company, door_group: door_group
    rfid_token = create_rfid_token member: member
    assert RfidToken.access_permitted?(rfid_token, door)
  end

  test "checking that the door should not be allowed to open if the token is inactive" do
    company = create_company
    member = create_member company: company
    door_group = create_door_group
    door = create_door door_group: door_group
    rfid_token = create_rfid_token member: member, active: false
    refute RfidToken.access_permitted?(rfid_token, door)
  end

  test "the door should not be allowed to open if the member is inactive" do
    company = create_company
    member = create_member company: company, active: false
    door_group = create_door_group
    door = create_door door_group: door_group
    rfid_token = create_rfid_token member: member
    refute RfidToken.access_permitted?(rfid_token, door)
  end

  test "the door should not be allowed to open if the company departed" do
    {:ok, departure} = Ecto.DateTime.cast("2015-04-30 00:00:00")
    company = create_company departure_date: departure
    member = create_member company: company
    door_group = create_door_group
    door = create_door door_group: door_group
    rfid_token = create_rfid_token member: member
    refute RfidToken.access_permitted?(rfid_token, door)
  end

  test "that the RFID Token identifier enforces uniqueness" do
    rfid_token_identifier = "abcd1234"
    company = create_company
    member = create_member company: company
    rfid_token1 = create_rfid_token member: member, identifier: rfid_token_identifier
    changeset = RfidToken.changeset(%RfidToken{member_id: member.id, identifier: rfid_token_identifier})
    assert {:error, message} = Repo.insert changeset
  end

  test "that an RfidToken object is auto-created when an unrecognized badge is scanned" do
    rfid_token_identifier = "this_is_an_unrecognized_token_id"
    door = create_door
    refute RfidToken.attempt_access!(rfid_token_identifier, door.id)
    assert Repo.get_by(RfidToken, %{identifier: rfid_token_identifier})
  end

  test "that an DoorAccessAttempt object is auto-created when an unrecognized badge is scanned" do
    rfid_token_identifier = "this_is_another_unrecognized_token_id"
    door = create_door
    refute RfidToken.attempt_access!(rfid_token_identifier, door.id)
    rfid_token = Repo.get_by(RfidToken, %{identifier: rfid_token_identifier})
    assert Repo.get_by(DoorAccessAttempt, %{rfid_token_id: rfid_token.id, door_id: door.id})
  end

  test "it displays the name when a name is provided" do
    name = "My RFID Token"
    rfid_token = create_rfid_token name: name
    assert name == RfidToken.display_name(rfid_token)
  end

  test "it displays the identifier when a name is not provided" do
    rfid_token = create_rfid_token
    assert rfid_token.identifier == RfidToken.display_name(rfid_token)
  end
end
