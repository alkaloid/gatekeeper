defmodule Gatekeeper.CompanyTest do
  use Gatekeeper.ModelCase

  alias Gatekeeper.Company

  @valid_attrs %{departure_date: "2010-04-17 14:00:00", join_date: "2010-04-17 14:00:00", name: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Company.changeset(%Company{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Company.changeset(%Company{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "checking an active company" do
    c = %Company{departure_date: nil}
    assert Company.active?(c)
  end

  test "checking an inactive company" do
    c = %Company{departure_date: "2015-04-30 00:00:00"}
    refute Company.active?(c)
  end
end
