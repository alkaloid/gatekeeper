defmodule Gatekeeper.RfidTokenTest do
  use Gatekeeper.ModelCase
  import Gatekeeper.Factory

  alias Gatekeeper.RfidToken

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
    assert RfidToken.access_permitted?(rfid_token.identifier, door.id)
  end

  test "checking that the door should not be allowed to open if the token is inactive" do
    company = create_company
    member = create_member company: company
    door_group = create_door_group
    door = create_door door_group: door_group
    rfid_token = create_rfid_token member: member, active: false
    refute RfidToken.access_permitted?(rfid_token.identifier, door.id)
  end

  test "the door should not be allowed to open if the member is inactive" do
    company = create_company
    member = create_member company: company, active: false
    door_group = create_door_group
    door = create_door door_group: door_group
    rfid_token = create_rfid_token member: member
    refute RfidToken.access_permitted?(rfid_token.identifier, door.id)
  end

  test "the door should not be allowed to open if the company departed" do
    {:ok, departure} = Ecto.DateTime.cast("2015-04-30 00:00:00")
    company = create_company departure_date: departure
    member = create_member company: company
    door_group = create_door_group
    door = create_door door_group: door_group
    rfid_token = create_rfid_token member: member
    refute RfidToken.access_permitted?(rfid_token.identifier, door.id)
  end

  test "the door should not be allowed to open if the token is not enrolled" do
    door_group = create_door_group
    door = create_door door_group: door_group
    refute RfidToken.access_permitted?("does_not_exist", door.id)
  end

  test "that the RFID Token identifier enforces uniqueness" do
    {:ok, departure} = Ecto.DateTime.cast("2015-04-30 00:00:00")
    {:ok, company} = Gatekeeper.Repo.insert %Company{departure_date: departure}
    {:ok, member} = Gatekeeper.Repo.insert %Member{active: true, company_id: company.id}
    {:ok, token1} = Gatekeeper.Repo.insert %RfidToken{identifier: "abcd1234", active: true, member_id: member.id}
    {:error, message} = Gatekeeper.Repo.insert %RfidToken{identifier: "abcd1234", active: true, member_id: member.id}

  end
end
