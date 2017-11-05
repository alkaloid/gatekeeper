defmodule Gatekeeper.RfidToken do
  use GatekeeperWeb, :model

  alias Gatekeeper.RfidToken
  alias Gatekeeper.Member
  alias Gatekeeper.Repo
  use Gatekeeper.WriteRepo # allow for hacky override of WriteRepo for tests
  alias Gatekeeper.WriteRepoWrapper
  alias Gatekeeper.Door
  alias Gatekeeper.DoorAccessAttempt

  # Write the access attempt synchronously for the test suite
  @async Application.get_env(:gatekeeper, Gatekeeper.Features)[:async_writes]

  schema "rfid_tokens" do
    field :identifier, :string
    field :name, :string
    field :active, :boolean, default: true
    belongs_to :member, Member
    has_many :door_access_attempts, DoorAccessAttempt

    timestamps()
  end

  @required_fields [:identifier, :active]
  @optional_fields [:name, :member_id]

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:identifier)
  end

  def active?(rfid_token) do
    rfid_token = Repo.preload(rfid_token, :member)

    if rfid_token.active do
      Member.active?(rfid_token.member)
    else
      {false, "rfid_token_inactive"}
    end
  end

  def display_name(rfid_token) do
    rfid_token.name || rfid_token.identifier
  end

  def access_permitted?(rfid_token, door) do
    at = Application.get_env(:gatekeeper, :system)[:timezone]
         |> Timex.now
    access_permitted?(rfid_token, door, at)
  end
  def access_permitted?(rfid_token, door, at) do
    rfid_token = Repo.preload(rfid_token, [:member])

    {allowed, reason} = active?(rfid_token)

    if allowed do
      Door.member_access_allowed?(door, rfid_token.member, at)
    else
      {allowed, reason}
    end
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

    %{rfid_token_id: rfid_token.id, door_id: door.id, access_allowed: allowed, reason: reason, member_id: rfid_token.member_id}
    |> WriteRepoWrapper.create_access_attempt(@async)

    {allowed, reason}
  end

  def autocreate_rfid_token(identifier) do
    change = changeset(%Gatekeeper.RfidToken{}, %{identifier: identifier, active: false})
    WriteRepo.insert! change
  end
end
