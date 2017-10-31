defmodule Gatekeeper.Door do
  use GatekeeperWeb, :model

  alias Gatekeeper.Repo
  alias Gatekeeper.Door
  alias Gatekeeper.DoorGroup
  alias Gatekeeper.DoorGroupDoor
  alias Gatekeeper.DoorGroupSchedule
  alias Gatekeeper.DoorAccessAttempt

  import Ecto.Query

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

  def member_access_allowed?(door, member, at \\ Timex.now()) do
    query = Door 
            |> where([door], door.id == ^door.id) 
            |> join(:inner, [door], door_group in assoc(door, :door_groups)) 
            |> join(:inner, [..., door_group], company in assoc(door_group, :companies)) 
            |> join(:inner, [..., company], member in assoc(company, :members)) 
            |> where([..., member], member.id == ^member.id) 

    count = Repo.aggregate(query, :count, :id)
    if (count > 0) do
      query = query
              |> join(:inner, [_, door_group, ...], door_group_schedule in assoc(door_group, :door_group_schedules))
              |> DoorGroupSchedule.open_at(at)

      count = Repo.aggregate(query, :count, :id)

      if (count > 0) do
        {true, "access_allowed"}
      else
        {false, "outside_hours"}
      end
    else
      {false, "no_access_to_door"}
    end
  end

  @doc """
  Returns a list of all members who have access to this dor at the specified time

  Membership may be directly or through a company. In both cases, the memberships
  are resolved through DoorGroups.
  """
  def members_with_access(door, now) do
    schedule_query = DoorGroup
    |> join(:inner, [door_group], dgs in assoc(door_group, :door_group_schedules))
    |> DoorGroupSchedule.open_at(now)

    door = Repo.preload(door, [door_groups: {schedule_query, [companies: :members]}])
    companies = Enum.reduce([ [] | door.door_groups ], &(&2 ++ &1.companies))
    Enum.reduce([ [] | companies ], &(&2 ++ &1.members))
  end
end
