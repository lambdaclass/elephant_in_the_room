defmodule ElephantInTheRoomWeb.SharedPostCardView do
  use ElephantInTheRoomWeb, :view
  import ElephantInTheRoomWeb.Utils.ViewUtils

  def show_link_with_date(conn, site, post) do
    year = site.inserted_at.year
    month = site.inserted_at.month
    day = site.inserted_at.day

    post_path(conn, :public_show, site.id, year, month, day, post.slug)
  end
end
