defmodule Gatekeeper.RfidToken do
  use Gatekeeper.Web, :model

  alias Gatekeeper.Member
  alias Gatekeeper.Repo

  schema "rfid_tokens" do
    field :identifier, :string
    field :name, :string
    field :active, :boolean, default: true
    belongs_to :member, Member

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

  def active?(rfid_token) do
    rfid_token = Repo.preload(rfid_token, :member)

    rfid_token.active && Member.active?(rfid_token.member)
  end

  def access_permitted?(rfid_token) do
    # TODO: Take a door as another argument and perform authz
    active?(rfid_token)
  end
end
