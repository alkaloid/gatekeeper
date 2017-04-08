defmodule Gatekeeper.Repo.Migrations.AddReasonAndMemberToDoorAccessAttempt do
  use Ecto.Migration

  def change do
    alter table(:door_access_attempts) do
      add :member_id, references(:members)
      add :reason, :string
    end
  end
end
