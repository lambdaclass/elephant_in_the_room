defmodule ElephantInTheRoomWeb.PostView do
  use ElephantInTheRoomWeb, :view
  alias ElephantInTheRoom.Sites

  def mk_assigns(conn, assigns, site) do
    if !(Map.has_key?(assigns, "categories") and Map.has_key?(assigns, "tags")) do
      Map.put(assigns, :action, site_post_path(conn, :create, site))
    else
      Map.put(assigns, :action, site_post_path(conn, :create, site, assigns.categories))
    end
  end

  def show_categories(site) do
    Sites.list_categories(site) |> Enum.map(& &1.name)
  end
end
