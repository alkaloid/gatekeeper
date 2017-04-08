defmodule Gatekeeper.Repo.Migrations.AddRoleToMembers do
  use Ecto.Migration

  def change do
    alter table(:members) do
      add :role, :string
    end
  end
end
