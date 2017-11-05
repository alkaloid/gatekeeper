defmodule Release.Tasks do  
  def migrate do
    {:ok, _} = Application.ensure_all_started(:gatekeeper)

    path = Application.app_dir(:gatekeeper, "priv/write_repo/migrations")

    Ecto.Migrator.run(Gatekeeper.WriteRepo, path, :up, all: true)
  end
end  
