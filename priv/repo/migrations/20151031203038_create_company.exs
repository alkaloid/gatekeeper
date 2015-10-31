defmodule Gatekeeper.Repo.Migrations.CreateCompany do
  use Ecto.Migration

  def change do
    create table(:companies) do
      add :name, :string
      add :join_date, :datetime
      add :departure_date, :datetime

      timestamps
    end

  end
end
