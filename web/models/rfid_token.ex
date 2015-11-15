defmodule Gatekeeper.RfidToken do
  use Gatekeeper.Web, :model

  alias Gatekeeper.Member
  alias Gatekeeper.Repo
  alias Gatekeeper.Door
  alias Gatekeeper.DoorAccessAttempt

  schema "rfid_tokens" do
    field :identifier, :string
    field :name, :string
    field :active, :boolean, default: true
    belongs_to :member, Member
    has_many :door_access_attempts, DoorAccessAttempt

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
    |> unique_constraint(:identifier)
  end

  def active?(rfid_token) do
    rfid_token = Repo.preload(rfid_token, :member)

    rfid_token.active && Member.active?(rfid_token.member)
  end

  def access_permitted?(identifier, door_id) do
    case Repo.get_by(Gatekeeper.RfidToken, identifier: identifier) do
      nil ->
        false
      rfid_token ->
        rfid_token = Repo.preload(rfid_token, :member)
    end
    door = Repo.get!(Gatekeeper.Door, door_id)
    rfid_token && active?(rfid_token) && Door.member_access_allowed?(door, rfid_token.member)
  end
end
