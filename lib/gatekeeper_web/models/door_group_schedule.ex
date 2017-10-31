defmodule Gatekeeper.DoorGroupSchedule do
  use GatekeeperWeb, :model

  alias Gatekeeper.DoorGroup
  alias Gatekeeper.DoorGroupSchedule
  use Gatekeeper.WriteRepo

  import Ecto.Query

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
    |> cast(params, ~w(door_group_id day_of_week start_time end_time)a)
    |> validate_required(~w(day_of_week start_time end_time)a)
    |> assoc_constraint(:door_group)
  end

  def open_at(query, datetime) do
    {:ok, day_of_week} = Timex.format(datetime, "%A", :strftime)
    {:ok, time_of_day} = Timex.format(datetime, "%H:%M:%S", :strftime)

    query
    |> where([..., dgs], dgs.day_of_week == ^day_of_week)
    |> where([..., dgs], dgs.start_time < ^time_of_day)
    |> where([..., dgs], dgs.end_time > ^time_of_day)
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
