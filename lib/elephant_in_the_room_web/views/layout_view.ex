defmodule ElephantInTheRoomWeb.LayoutView do
  use ElephantInTheRoomWeb, :view
  alias ElephantInTheRoom.Sites

  def get_nav_sites() do
    Sites.list_sites
    |> Enum.map(fn(x) ->
      {x.id, x.name}
    end)
  end

  def get_categories(conn) do
    site = conn.assigns.site
    site.categories
    |> Enum.map(fn(x) ->
      {x.id, x.name}
    end)
  end

  def in_current_site(conn, site_id) do
    current_site = conn.assigns[:site]
    case current_site do
      nil -> false
      _ -> current_site.id == site_id
    end
    
  end

  
end
