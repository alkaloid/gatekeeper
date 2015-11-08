defmodule Gatekeeper.DoorGroupTest do
  use Gatekeeper.ModelCase

  alias Gatekeeper.DoorGroup

  @valid_attrs %{name: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = DoorGroup.changeset(%DoorGroup{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = DoorGroup.changeset(%DoorGroup{}, @invalid_attrs)
    refute changeset.valid?
  end
end
