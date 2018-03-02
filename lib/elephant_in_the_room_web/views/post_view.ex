defmodule ElephantInTheRoomWeb.PostView do
  use ElephantInTheRoomWeb, :view
  alias ElephantInTheRoom.Sites

  def mk_assigns(conn, assigns, site, post) do
    IO.puts("BIEN")
    IO.puts(inspect(assigns.categories))

    assigns
    |> Map.put(:action, site_post_path(conn, :update, site, post))
    |> Map.put(:categories, site.categories)
  end

  #   if !Map.has_key?(assigns, "categories") do
  #     IO.puts("MAL")
  #     Map.put(assigns, :action, site_post_path(conn, :update, site, post))
  #   else
  #     IO.puts("Categorias" <> inspect(assigns.categories))
  #     Map.put(assigns, :action, site_post_path(conn, :update, site, post, assigns.categories))
  #   end
  # end

  def mk_assigns(conn, assigns, site) do
    if !Map.has_key?(assigns, "categories") do
      Map.put(assigns, :action, site_post_path(conn, :create, site))
    else
      Map.put(assigns, :action, site_post_path(conn, :create, site, assigns.categories))
    end
  end

  def show_categories(site) do
    site
    |> Sites.list_categories()
    |> Enum.map(fn category -> category.name end)
  end
end
