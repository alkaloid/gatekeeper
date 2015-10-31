defmodule Gatekeeper.PageController do
  use Gatekeeper.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
