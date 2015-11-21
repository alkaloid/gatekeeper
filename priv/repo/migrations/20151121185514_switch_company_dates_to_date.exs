defmodule Gatekeeper.Repo.Migrations.SwitchCompanyDatesToDate do
  use Ecto.Migration

  def change do
    alter table(:companies) do
      modify :join_date, :date
      modify :departure_date, :date
    end
  end
end
