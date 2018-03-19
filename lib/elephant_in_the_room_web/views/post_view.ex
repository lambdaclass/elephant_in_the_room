defmodule ElephantInTheRoomWeb.PostView do
  use ElephantInTheRoomWeb, :view
  alias ElephantInTheRoom.Sites.Post
  alias ElephantInTheRoom.Sites
  alias ElephantInTheRoom.Repo

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

  def put_commas(post, key) do
    if Map.has_key?(post, key) do
      post = Repo.preload(post, key)

      Map.get(post, key)
      |> Enum.map(fn t -> t.name end)
      |> Enum.intersperse(", ")
    else
      ""
    end
  end

  def show_featured_category(%Post{categories: categories}) do
    case categories do
      [] -> ""
      [featured_category | _] -> featured_category.name
    end
  end
  
end
