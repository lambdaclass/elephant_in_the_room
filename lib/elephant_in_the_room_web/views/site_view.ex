defmodule ElephantInTheRoomWeb.SiteView do
  use ElephantInTheRoomWeb, :view

  alias ElephantInTheRoomWeb.SharedPostCardView

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

  def get_important_posts_left(_conn, posts) do
    case posts do
      [_top | rest] ->
        {:ok, Enum.take(rest, 2)}

      [] ->
        {:error, :no_important_posts_left}
    end
  end

  def get_important_posts_right(_conn, posts) do
    case posts do
      [_ | rest] ->
        {:ok, rest |> Enum.drop(2) |> Enum.take(4)}

      _ ->
        {:error, :no_important_posts_right}
    end
  end

  def get_normal_posts(_conn, posts) do
    case posts do
      [_ | normal_posts] ->
        {:ok, Enum.drop(normal_posts, 6)}

      _ ->
        {:error, :no_normal_posts}
    end
  end

  def number_of_entries(entries, entries_per_page) do
    max(entries_per_page - entries, entries)
  end

  def show_link_with_date(conn, site, post) do
    year = post.inserted_at.year
    month = post.inserted_at.month
    day = post.inserted_at.day

    if conn.host != "localhost",
      do: post_path(conn, :public_show, year, month, day, post.slug),
      else: local_post_path(conn, :public_show, site.id, year, month, day, post.slug)
  end

  def show_site_link(site, conn) do
    if conn.host != "localhost",
      do: site_path(conn, :public_show),
      else: local_site_path(conn, :public_show, site.id)
  end

  def render_shared(template, assigns \\ []) do
    render(SharedPostCardView, template, assigns)
  end
end
