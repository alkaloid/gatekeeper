defmodule Gatekeeper.RfidTokenTest do
  use Gatekeeper.ModelCase

  alias Gatekeeper.RfidToken
  alias Gatekeeper.Member
  alias Gatekeeper.Company

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
    m = %RfidToken{active: true, member: %Member{active: true, company: %Company{departure_date: nil}}}
    assert RfidToken.active?(m)
  end

  test "checking for an inactive RFID token" do
    m = %RfidToken{active: false, member: %Member{active: true, company: %Company{departure_date: nil}}}
    refute RfidToken.active?(m)
  end

  test "checking for an inactive member" do
    m = %RfidToken{active: true, member: %Member{active: false, company: %Company{departure_date: nil}}}
    refute RfidToken.active?(m)
  end

  test "checking for an inactive company" do
    m = %RfidToken{active: true, member: %Member{active: true, company: %Company{departure_date: "2015-04-30 00:00:00"}}}
    refute RfidToken.active?(m)
  end

  test "checking that the door should be allowed to open" do
    {:ok, company} = Gatekeeper.Repo.insert %Company{departure_date: nil}
    {:ok, member} = Gatekeeper.Repo.insert %Member{active: true, company_id: company.id}
    Gatekeeper.Repo.insert %RfidToken{identifier: "abcd1234", active: true, member_id: member.id}
    assert RfidToken.access_permitted?("abcd1234")
  end

  test "checking that the door should not be allowed to open" do
      {:ok, company} = Gatekeeper.Repo.insert %Company{departure_date: nil}
    {:ok, member} = Gatekeeper.Repo.insert %Member{active: true, company_id: company.id}
    Gatekeeper.Repo.insert %RfidToken{identifier: "abcd1234", active: false, member_id: member.id}
    refute RfidToken.access_permitted?("abcd1234")
  end
end
