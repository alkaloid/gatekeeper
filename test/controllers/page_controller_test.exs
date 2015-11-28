defmodule Gatekeeper.PageControllerTest do
  use Gatekeeper.ConnCase

  test "GET /" do
    conn = get conn(), "/"
    assert html_response(conn, 200) =~ "Alkaloid Gatekeeper"
  end

  test "permits unauthenticated requests" do
    conn = get conn, page_path(conn, :index)
    assert html_response(conn, 200)
  end
end
