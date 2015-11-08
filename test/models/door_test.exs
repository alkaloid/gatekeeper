defmodule Gatekeeper.DoorTest do
  use Gatekeeper.ModelCase

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
end
