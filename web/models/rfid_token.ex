defmodule Gatekeeper.RfidToken do
  use Gatekeeper.Web, :model

  schema "rfid_tokens" do
    field :identifier, :string
    field :name, :string
    field :active, :boolean, default: true
    belongs_to :member, Gatekeeper.Member

    timestamps
  end

  @required_fields ~w(identifier active member_id)
  @optional_fields ~w(name)

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
