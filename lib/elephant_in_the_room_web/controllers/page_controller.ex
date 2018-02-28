defmodule ElephantInTheRoomWeb.PageController do
  use ElephantInTheRoomWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
