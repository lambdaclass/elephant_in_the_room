defmodule ElephantInTheRoomWeb.FeaturedController do
  use ElephantInTheRoomWeb, :controller
  # alias ElephantInTheRoom.Sites.Site
  #alias ElephantInTheRoom.{Sites, Repo}

  def show_featured_levels(conn, _params) do
    render(conn, "show_featured_levels.html")
  end

end
