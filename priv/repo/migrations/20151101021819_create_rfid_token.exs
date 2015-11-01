defmodule Gatekeeper.Repo.Migrations.CreateRfidToken do
  use Ecto.Migration

  def change do
    create table(:rfid_tokens) do
      add :identifier, :string
      add :name, :string
      add :member_id, references(:members)

      timestamps
    end
    create index(:rfid_tokens, [:member_id])

  end
end
