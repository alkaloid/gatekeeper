defmodule Gatekeeper.Repo.Migrations.CreateDoorGroup do
  use Ecto.Migration

  def change do
    create table(:door_groups) do
      add :name, :string

      timestamps
    end

  end
end
