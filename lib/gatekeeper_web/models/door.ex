defmodule Gatekeeper.Door do
  use GatekeeperWeb, :model

  alias Gatekeeper.Repo
  alias Gatekeeper.DoorGroupDoor
  alias Gatekeeper.DoorAccessAttempt

  schema "doors" do
    field :name, :string
    has_many :door_group_doors, DoorGroupDoor
    has_many :door_groups, through: [:door_group_doors, :door_group]
    has_many :access_attempts, DoorAccessAttempt

    timestamps()
  end

  @required_fields [:name]
  @optional_fields []

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end

  def member_access_allowed?(door, member) do
    if member.id in Enum.map(members(door), &(&1.id)) do
      {true, "access_allowed"}
    else
      {false, "no_access_to_door"}
    end
  end

  def members(door) do
    door = Repo.preload(door, [door_groups: [companies: :members]])
    companies = Enum.reduce([ [] | door.door_groups ], &(&2 ++ &1.companies))
    Enum.reduce([ [] | companies ], &(&2 ++ &1.members))
  end
end
