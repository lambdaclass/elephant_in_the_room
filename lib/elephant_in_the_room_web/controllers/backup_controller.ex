defmodule ElephantInTheRoomWeb.BackupController do
  use ElephantInTheRoomWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end


end