defmodule Gatekeeper.Repo.Migrations.CreateDoorGroupMember do
  use Ecto.Migration

  def change do
    create table(:door_group_members) do
      add :door_group_id, :integer
      add :member_id, references(:members)

      timestamps
    end

  end
end
