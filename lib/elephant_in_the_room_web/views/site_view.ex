defmodule ElephantInTheRoomWeb.SiteView do
  use ElephantInTheRoomWeb, :view
  import ElephantInTheRoomWeb.Utils.ViewUtils

  def get_top_featured_post(_conn, posts) do
    case posts do
      [top | _] -> {:ok, top}
      [] -> {:error, :no_top_featured}
    end
  end

  def get_normal_posts(_conn, posts) do
    case posts do
      [_ | normal_posts] -> {:ok, normal_posts}
      _ -> {:error, :no_normal_posts}
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
end
