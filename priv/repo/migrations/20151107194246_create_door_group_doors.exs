defmodule Gatekeeper.Repo.Migrations.CreateDoorGroupDoors do
  use Ecto.Migration

  def change do
    create table(:door_group_doors) do
      add :door_group_id, :integer
      add :door_id, :integer

      timestamps
    end

  end
end
