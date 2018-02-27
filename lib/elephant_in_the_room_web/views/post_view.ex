defmodule ElephantInTheRoomWeb.PostView do
  use ElephantInTheRoomWeb, :view

  def mk_assigns(conn, assigns, site) do
    IO.puts(inspect(assigns.tags))

    if !(Map.has_key?(assigns, "categories") and Map.has_key?(assigns, "tags")) do
      Map.put(assigns, :action, site_post_path(conn, :create, site))
    else
      map = Map.put(assigns, :action, site_post_path(conn, :create, site, assigns.categories))
      Map.put(map, :tags, assigns.tags)
    end
  end

  def show_select(list) do
    list |> Enum.map(& &1.name)
  end
end
