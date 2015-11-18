defmodule Gatekeeper.Door do
  use Gatekeeper.Web, :model

  alias Gatekeeper.Repo
  alias Gatekeeper.DoorGroupDoor
  alias Gatekeeper.DoorAccessAttempt

  schema "doors" do
    field :name, :string
    has_many :door_group_doors, DoorGroupDoor
    has_many :door_groups, through: [:door_group_doors, :door_group]
    has_many :access_attempts, DoorAccessAttempt

    timestamps
  end

  @required_fields ~w(name)
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

  def member_access_allowed?(door, member) do
    member.id in Enum.map(members(door), &(&1.id))
  end

  def members(door) do
    door = Repo.preload(door, [door_groups: [:members, companies: :members]])
    members = Enum.reduce([ [] | door.door_groups ], &(&2 ++ &1.members))
    companies = Enum.reduce([ [] | door.door_groups ], &(&2 ++ &1.companies))
    company_members = Enum.reduce([ [] | companies ], &(&2 ++ &1.members))
    members ++ company_members
  end
end
