defmodule Gatekeeper.RfidToken do
  use Gatekeeper.Web, :model

  alias Gatekeeper.RfidToken
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

  @required_fields ~w(identifier active)
  @optional_fields ~w(name member_id)

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

    if rfid_token.active do
      {allowed, reason} = Member.active?(rfid_token.member)
    else
      {allowed, reason} = {false, "rfid_token_inactive"}
    end

    {allowed, reason}
  end

  def display_name(rfid_token) do
    rfid_token.name || rfid_token.identifier
  end

  def access_permitted?(rfid_token, door) do
    rfid_token = Repo.preload(rfid_token, [:member])

    {allowed, reason} = active?(rfid_token)

    if allowed do
      {allowed, reason} = Door.member_access_allowed?(door, rfid_token.member)
    end

    {allowed, reason}
  end

  def attempt_access!(identifier, door_id) do
    rfid_token = case Repo.get_by(RfidToken, identifier: identifier) do
      nil ->
        autocreate_rfid_token identifier
      rfid_token ->
        rfid_token
    end |> Repo.preload(:member)

    door = Repo.get!(Door, door_id)

    {allowed, reason} = access_permitted? rfid_token, door
    create_access_attempt rfid_token, door, allowed, reason, rfid_token.member_id

    {allowed, reason}
  end

  def autocreate_rfid_token(identifier) do
    change = changeset(%Gatekeeper.RfidToken{}, %{identifier: identifier, active: false})
    Repo.insert! change
  end

  def create_access_attempt(rfid_token, door, allowed, reason, member_id) do
    changeset = DoorAccessAttempt.changeset(%DoorAccessAttempt{}, %{rfid_token_id: rfid_token.id, door_id: door.id, access_allowed: allowed, reason: reason, member_id: member_id})
    Repo.insert! changeset
  end
end
