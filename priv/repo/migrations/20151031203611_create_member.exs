defmodule Gatekeeper.Repo.Migrations.CreateMember do
  use Ecto.Migration

  def change do
    create table(:members) do
      add :name, :string
      add :email, :string
      add :phone, :string
      add :active, :boolean, default: false
      add :company_id, references(:companies)

      timestamps
    end
    create index(:members, [:company_id])

  end
end
