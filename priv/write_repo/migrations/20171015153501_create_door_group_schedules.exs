defmodule Gatekeeper.Repo.Migrations.CreateDoorGroupSchedules do
  use Ecto.Migration

  alias Gatekeeper.WriteRepo
  alias Gatekeeper.DoorGroup
  alias Gatekeeper.DoorGroupSchedule

  def up do
    create table(:door_group_schedules) do
      add :door_group_id, references(:door_groups)
      add :day_of_week, :string
      add :start_time, :time
      add :end_time, :time

      timestamps()
    end

    flush()

    for door_group <- WriteRepo.all(DoorGroup) do
      DoorGroupSchedule.create_default_schedule! door_group
    end
  end

  def down do
    drop table(:door_group_schedules)
  end
end
