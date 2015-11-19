defmodule Gatekeeper.Member do
  use Gatekeeper.Web, :model

  alias Gatekeeper.Company
  alias Gatekeeper.Repo
  alias Gatekeeper.RfidToken
  alias Gatekeeper.DoorGroupMember

  schema "members" do
    field :name, :string
    field :email, :string
    field :phone, :string
    field :active, :boolean, default: true
    belongs_to :company, Company
    has_many :rfid_tokens, RfidToken

    has_many :door_group_members, DoorGroupMember
    has_many :door_groups, through: [:door_group_members, :door_group]
    has_many :doors, through: [:door_groups, :door]
    has_many :door_access_attempts, DoorAccessAttempt

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
    |> foreign_key_constraint(:company_id)
  end

  def active?(member) do
    member = Repo.preload member, :company

    if member.active do
      if Company.active?(member.company) do
        {allowed, reason} = {true, :access_allowed}
      else
        {allowed, reason} = {false, :company_inactive}
      end
    else
      {allowed, reason} = {false, :member_inactive}
    end

    {allowed, reason}
  end
end
