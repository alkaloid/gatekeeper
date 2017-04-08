defmodule Gatekeeper.Repo.Migrations.AddUniqueConstraintToRfidTokenIdentifier do
  use Ecto.Migration

  def change do
    create unique_index(:rfid_tokens, [:identifier])
  end
end
