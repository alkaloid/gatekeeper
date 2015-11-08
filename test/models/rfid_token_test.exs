defmodule Gatekeeper.RfidTokenTest do
  use Gatekeeper.ModelCase

  alias Gatekeeper.RfidToken
  alias Gatekeeper.Member
  alias Gatekeeper.Company

  @valid_attrs %{identifier: "some content", active: false, member_id: 1}
  @invalid_attrs %{}

  def create_company(params \\ %{}) do
    default_params = %{
      name: "Test Company",
      join_date: :calendar.local_time(),
      departure_date: nil
    }
    params = Dict.merge(default_params, params)
    changeset = Company.changeset(%Company{}, params)
    {:ok, company} = Repo.insert(changeset)
    company
  end

  def create_member(params \\ %{}) do
    default_params = %{
      name: "Test Member",
      email: "test@example.com",
      active: true
    }
    # :company is a required parameter
    default_params = Dict.merge(default_params, company_id: params[:company].id)

    params = Dict.merge(default_params, params)
    changeset = Member.changeset(%Member{}, params)
    {:ok, member} = Repo.insert(changeset)
    member
  end

  def create_rfid_token(params \\ %{}) do
    default_params = %{
      identifier: "abcd1234",
      active: true,
    }
    # :member is a required parameter
    default_params = Dict.merge(default_params, member_id: params[:member].id)

    params = Dict.merge(default_params, params)
    changeset = RfidToken.changeset(%RfidToken{}, params)
    {:ok, rfid_token} = Repo.insert(changeset)
    rfid_token
  end

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
    member = create_member company: company
    rfid_token = create_rfid_token member: member
    assert RfidToken.access_permitted?("abcd1234")
  end

  test "checking that the door should not be allowed to open if the token is inactive" do
    company = create_company
    member = create_member company: company
    rfid_token = create_rfid_token member: member, active: false
    refute RfidToken.access_permitted?("abcd1234")
  end

  test "the door should not be allowed to open if the member is inactive" do
    company = create_company
    member = create_member company: company, active: false
    rfid_token = create_rfid_token member: member
    refute RfidToken.access_permitted?("abcd1234")
  end

  test "the door should not be allowed to open if the company departed" do
    {:ok, departure} = Ecto.DateTime.cast("2015-04-30 00:00:00")
    company = create_company departure_date: departure
    member = create_member company: company
    rfid_token = create_rfid_token member: member
    refute RfidToken.access_permitted?("abcd1234")
  end

  test "the door should not be allowed to open if the token is not enrolled" do
    refute RfidToken.access_permitted?("abcd1234")
  end
end
