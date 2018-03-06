defmodule ElephantInTheRoomWeb.AdminController do
  use ElephantInTheRoomWeb, :controller
  alias ElephantInTheRoom.Sites
  
  def index(conn, _params) do
    sites = Sites.list_sites()
    render(conn, "index.html", sites: sites)
  end
  
end
