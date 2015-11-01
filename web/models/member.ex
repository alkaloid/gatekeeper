defmodule Gatekeeper.Member do
  use Gatekeeper.Web, :model

  schema "members" do
    field :name, :string
    field :email, :string
    field :phone, :string
    field :active, :boolean, default: false
    belongs_to :company, Gatekeeper.Company
    has_many :rfid_tokens, Gatekeeper.RfidTokens

    timestamps
  end

  @required_fields ~w(name email active company_id)
  @optional_fields ~w(phone)

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
