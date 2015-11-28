defmodule Gatekeeper.PageController do
  use Gatekeeper.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def unauthenticated(conn, _params) do
    conn
    |> put_flash(:error, "You must log in to view that page")
    |> redirect(to: "/")
  end
end
