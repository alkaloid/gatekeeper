defmodule Gatekeeper.RfidTokenTest do
  use Gatekeeper.ModelCase

  alias Gatekeeper.RfidToken

  @valid_attrs %{identifier: "some content"}
  @invalid_attrs %{}

  @tag :skip
  test "changeset with valid attributes" do
    changeset = RfidToken.changeset(%RfidToken{}, @valid_attrs)
    assert changeset.valid?
  end

  @tag :skip
  test "changeset with invalid attributes" do
    changeset = RfidToken.changeset(%RfidToken{}, @invalid_attrs)
    refute changeset.valid?
  end
end
