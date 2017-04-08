defmodule Gatekeeper.DoorGroupDoor do
  use Gatekeeper.Web, :model

  schema "door_group_doors" do
    belongs_to :door_group, Gatekeeper.DoorGroup
    belongs_to :door, Gatekeeper.Door

    timestamps
  end

  @required_fields ~w(door_group_id door_id)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
