defmodule ElephantInTheRoomWeb.CategoryView do
  use ElephantInTheRoomWeb, :view
  alias ElephantInTheRoom.{Repo, Posts.Post}
  alias ElephantInTheRoomWeb.Utils.Utils
  import Ecto.Query

  def get_top_featured_post(_conn, posts) do
    case posts do
      [top | _] -> {:ok, top}
      [] -> {:error, :no_top_featured}
    end
  end

  def get_important_posts(_conn, posts) do
    case posts do
      [_top | rest] ->
        {:ok, Enum.take(rest, 3)}

      [] ->
        {:error, :no_important_posts}
    end
  end

  def get_normal_posts(_conn, posts) do
    case posts do
      [_ | normal_posts] ->
        {:ok, Enum.drop(normal_posts, 4)}

      _ ->
        {:error, :no_normal_posts}
    end
  end

  def number_of_posts(category) do
    from(
      p in "posts_categories",
      where: p.category_id == type(^category.id, Ecto.UUID),
      select: count(p.post_id)
    )
    |> Repo.one()
  end

  def latest_posts(category, amount \\ 4) do
    cat_with_posts = Repo.preload(category, :posts)
    Enum.take(cat_with_posts.posts, amount)
  end

  def show_site_link(conn) do
    site_path(conn, :public_show)
  end

  def show_post_link(conn, %Post{inserted_at: date, slug: slug}) do
    post_path(conn, :public_show, date.year, date.month, date.day, slug)
    |> Utils.generate_absolute_url(conn)
  end
end
