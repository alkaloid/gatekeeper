defmodule Gatekeeper.MemberTest do
  use Gatekeeper.ModelCase

  alias Gatekeeper.Member
  alias Gatekeeper.Company

  @valid_attrs %{active: true, email: "some content", name: "some content", phone: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Member.changeset(%Member{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Member.changeset(%Member{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "checking an active member with an active company" do
    m = %Member{active: true, company: %Company{departure_date: nil}}
    assert Member.active?(m)
  end

  test "checking an active member with an inactive company" do
    m = %Member{active: true, company: %Company{departure_date: "2015-04-30 00:00:00"}}
    refute Member.active?(m)
  end

  test "checking an inactive member with an active company" do
    m = %Member{active: false, company: %Company{departure_date: nil}}
    refute Member.active?(m)
  end

  test "checking an inactive member with an inactive company" do
    m = %Member{active: false, company: %Company{departure_date: "2015-04-30 00:00:00"}}
    refute Member.active?(m)
  end
end
