defmodule ElephantInTheRoomWeb.SiteView do
  use ElephantInTheRoomWeb, :view

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

  def number_of_entries(entries, entries_per_page) do
    max(entries_per_page - entries, entries)
  end

  def show_link_with_date(conn, site, post) do
    year = post.inserted_at.year
    month = post.inserted_at.month
    day = post.inserted_at.day
    route1 = fn -> post_path(conn, :public_show, year, month, day, post.slug) end
    route2 = fn -> local_post_path(conn, :public_show, site.id, year, month, day, post.slug) end
    choose_route(conn, route1, route2)
  end

  def show_site_link(site, conn) do
    route1 = fn -> site_path(conn, :public_show) end
    route2 = fn -> local_site_path(conn, :public_show, site.id) end
    choose_route(conn, route1, route2)
  end
end
