defmodule Gatekeeper.PageControllerTest do
  use Gatekeeper.ConnCase

  test "GET /" do
    conn = get conn(), "/"
    assert html_response(conn, 200) =~ "Alkaloid Gatekeeper"
  end
end
