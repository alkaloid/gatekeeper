defmodule Gatekeeper.DoorGroupCompanyTest do
  use Gatekeeper.ModelCase

  alias Gatekeeper.DoorGroupCompany

  @valid_attrs %{company_id: 42, door_group_id: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = DoorGroupCompany.changeset(%DoorGroupCompany{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = DoorGroupCompany.changeset(%DoorGroupCompany{}, @invalid_attrs)
    refute changeset.valid?
  end
end
