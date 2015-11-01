defmodule Gatekeeper.Repo.Migrations.AddActiveFlagToRfidToken do
  use Ecto.Migration

  def change do
    alter table(:rfid_tokens) do
      add :active, :boolean, default: true
    end
  end
end
