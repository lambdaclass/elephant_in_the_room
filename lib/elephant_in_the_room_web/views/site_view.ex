defmodule ElephantInTheRoomWeb.SiteView do
  use ElephantInTheRoomWeb, :view
  alias Scrivener.Config
  alias ElephantInTheRoom.Repo

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

  def show_link_with_date(conn, site, post) do
    year = post.inserted_at.year
    month = post.inserted_at.month
    day = post.inserted_at.day

    post_path(conn, :public_show, site.id, year, month, day, post.slug)
  end

  def number_of_entries(entries, entries_per_page) do
    max(entries_per_page - entries, entries)
  end

  def pagination_config(page, page_size) do
    %Config{page_number: page, page_size: page_size}
  end

  def paginate_categories(categories, page, page_size) do
    config = pagination_config(page, page_size)

    categories
    |> Repo.paginate()
  end

  def paginate_tags(tags, page, page_size) do
    config = pagination_config(page, page_size)

    tags
    |> Repo.paginate()
  end

  def paginate_posts(posts, page, page_size) do
    config = pagination_config(page, page_size)

    posts
    |> Repo.paginate()
  end
end
