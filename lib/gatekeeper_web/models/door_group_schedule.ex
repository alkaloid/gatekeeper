defmodule Gatekeeper.DoorGroupSchedule do
  use GatekeeperWeb, :model

  alias Gatekeeper.DoorGroup
  alias Gatekeeper.DoorGroupSchedule
  use Gatekeeper.WriteRepo

  @days_of_week ["Sunday", "Monday", "Tuesday", "Wednesday",
                 "Thursday", "Friday", "Saturday"]

  schema "door_group_schedules" do
    belongs_to :door_group, DoorGroup
    field :day_of_week, :string
    field :start_time, :time
    field :end_time, :time

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:day_of_week, :start_time, :end_time])
    |> validate_required([:day_of_week, :start_time, :end_time])
  end

  def create_default_schedule!(door_group) do
    for day_of_week <- @days_of_week do
      params = %{
        door_group_id: door_group.id,
        day_of_week: day_of_week,
        start_time: "00:00:00.0",
        end_time: "23:59:59.999999"
      }

      {:ok, _} = changeset(%DoorGroupSchedule{}, params) |> WriteRepo.insert()
    end
  end
end
