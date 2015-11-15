defmodule Gatekeeper.DoorAccessAttempt do
  use Gatekeeper.Web, :model

  alias Gatekeeper.RfidToken
  alias Gatekeeper.Door

  schema "door_access_attempts" do
    belongs_to :rfid_token, RfidToken
    belongs_to :door, Door
    field :access_allowed, :boolean, default: false

    timestamps
  end

  @required_fields ~w(door_id rfid_token_id access_allowed)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
