ExUnit.start

Mix.Task.run "ecto.create", ["--quiet"]
Mix.Task.run "ecto.migrate", ["--quiet"]
Ecto.Adapters.SQL.begin_test_transaction(Gatekeeper.Repo)

ExUnit.configure(exclude: [skip: true])

Code.load_file "test/factory.exs"
