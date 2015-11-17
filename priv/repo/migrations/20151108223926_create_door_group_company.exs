defmodule Gatekeeper.Repo.Migrations.CreateDoorGroupCompany do
  use Ecto.Migration

  def change do
    create table(:door_group_companies) do
      add :door_group_id, :integer
      add :company_id, references(:companies)

      timestamps
    end

  end
end
