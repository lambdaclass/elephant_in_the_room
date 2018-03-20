defmodule ElephantInTheRoomWeb.SiteView do
  use ElephantInTheRoomWeb, :view

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
    site_id = site.id
    year = post.inserted_at.year
    month = post.inserted_at.month
    day = post.inserted_at.day

    post_path(conn, :public_show, site.id, year, month, day, post.slug)
  end
end
