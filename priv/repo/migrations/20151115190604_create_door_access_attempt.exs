defmodule Gatekeeper.Repo.Migrations.CreateDoorAccessAttempt do
  use Ecto.Migration

  def change do
    create table(:door_access_attempts) do
      add :door_id, :integer
      add :rfid_token_id, references(:rfid_tokens)
      add :access_allowed, :boolean, default: false

      timestamps
    end

  end
end
