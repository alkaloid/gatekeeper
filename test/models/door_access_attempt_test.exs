defmodule Gatekeeper.DoorAccessAttemptTest do
  use Gatekeeper.ModelCase

  alias Gatekeeper.DoorAccessAttempt

  @valid_attrs %{access_allowed: true, door_id: 42, rfid_token_id: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = DoorAccessAttempt.changeset(%DoorAccessAttempt{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = DoorAccessAttempt.changeset(%DoorAccessAttempt{}, @invalid_attrs)
    refute changeset.valid?
  end
end
