defmodule Gatekeeper.Member do
  use Gatekeeper.Web, :model

  alias Gatekeeper.Company
  alias Gatekeeper.Repo
  alias Gatekeeper.RfidToken
  alias Gatekeeper.DoorGroupMember
  alias Gatekeeper.DoorAccessAttempt

  schema "members" do
    field :name, :string
    field :email, :string
    field :phone, :string
    field :active, :boolean, default: true
    field :role, :string
    belongs_to :company, Company
    has_many :rfid_tokens, RfidToken

    has_many :door_group_members, DoorGroupMember
    has_many :door_groups, through: [:door_group_members, :door_group]
    has_many :doors, through: [:door_groups, :door]
    has_many :door_access_attempts, DoorAccessAttempt

    timestamps()
  end

  @required_fields [:name, :email, :active, :company_id, :role]
  @optional_fields [:phone]

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:company_id)
  end

  def active?(member) do
    member = Repo.preload member, :company

    if member.active do
      if Company.active?(member.company) do
        {true, "access_allowed"}
      else
        {false, "company_inactive"}
      end
    else
      {false, "member_inactive"}
    end
  end

  def active do
    from member in Gatekeeper.Member,
      where: member.active == true,
      preload: :company,
      order_by: :name
  end

  def all_active do
    Repo.all(Company.active)
    |> Repo.preload(members: active())
    |> Enum.reduce([], &(&2 ++ &1.members))
  end
end
