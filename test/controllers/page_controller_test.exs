defmodule Gatekeeper.PageControllerTest do
  use Gatekeeper.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "Alkaloid Gatekeeper"
  end

  test "permits unauthenticated requests", %{conn: conn} do
    conn = get conn, page_path(conn, :index)
    assert html_response(conn, 200)
  end
end
