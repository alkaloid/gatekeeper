defmodule Gatekeeper.DoorGroupScheduleTest do
  use Gatekeeper.ModelCase
  use Gatekeeper.WriteRepo # allow for hacky override of WriteRepo for tests

  import Gatekeeper.Factory

  alias Gatekeeper.DoorGroupSchedule

  test "finds schedules that are active for a given time" do
    create_door_group(door: create_door(), skip_default_schedule: true)

    create_door_group_schedule(day_of_week: "Monday")
    current_schedule = create_door_group_schedule(day_of_week: "Tuesday")
    create_door_group_schedule(day_of_week: "Wednesday")

    {:ok, now} = Timex.parse "2017-01-03T12:34:56", "{ISO:Extended}"

    schedules = DoorGroupSchedule
    |> DoorGroupSchedule.open_at(now)
    |> Gatekeeper.Repo.all
    assert schedules == [current_schedule]
  end
end
