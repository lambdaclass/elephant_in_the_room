defmodule ElephantInTheRoomWeb.PostView do
  use ElephantInTheRoomWeb, :view
  alias ElephantInTheRoom.Sites.Post
  alias ElephantInTheRoom.Sites

  def mk_assigns(conn, assigns, site, post) do
    assigns
    |> Map.put(:action, site_post_path(conn, :update, site, post))
    |> Map.put(:categories, site.categories)
  end

  def mk_assigns(conn, assigns, site) do
    if !Map.has_key?(assigns, "categories") do
      Map.put(assigns, :action, site_post_path(conn, :create, site))
    else
      Map.put(assigns, :action, site_post_path(conn, :create, site, assigns.categories))
    end
  end

  def show_categories(site) do
    site.categories
    |> Enum.map(fn category -> category.name end)
  end

  def get_authors() do
    Sites.list_authors() |> Enum.map(fn author -> {author.name, author.id} end)
  end

  def show_selected_categories(data) do
    if Map.has_key?(data, "categories") do
      Enum.map(data.categories, fn category -> category.name end)
    else
      []
    end
  end

  def show_content(%Post{rendered_content: content}), do: content

  def show_tags(data) do
    if Map.has_key?(data, :tags) do
      data.tags
      |> Enum.map(fn t -> t.name end)
      |> Enum.intersperse(", ")
    else
      ""
    end
  end
end
