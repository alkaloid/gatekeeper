ExUnit.start

Ecto.Adapters.SQL.Sandbox.mode(Gatekeeper.Repo, :manual)

ExUnit.configure(exclude: [skip: true])

Code.load_file "test/factory.exs"

defmodule Guardian.TestHelper do
  @default_opts [
    store: :cookie,
    key: "foobar",
    encryption_salt: "encrypted cookie salt",
    signing_salt: "signing salt"
  ]

  @secret String.duplicate("abcdef0123456789", 8)
  @signing_opts Plug.Session.init(Keyword.put(@default_opts, :encrypt, false))

  def conn_with_fetched_session(the_conn) do
    put_in(the_conn.secret_key_base, @secret)
    |> Plug.Session.call(@signing_opts)
    |> Plug.Conn.fetch_session
  end
end
