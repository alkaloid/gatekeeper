defmodule Gatekeeper.WriteRepo.Migrations.DropDoorGroupMembersTable do
  use Ecto.Migration

  def change do
    drop table(:door_group_members)
  end
end
