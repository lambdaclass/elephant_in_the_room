defmodule ElephantInTheRoomWeb.PageControllerTest do
  use ElephantInTheRoomWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Elephant"
  end
end
