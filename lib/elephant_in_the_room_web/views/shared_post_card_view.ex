defmodule ElephantInTheRoomWeb.SharedPostCardView do
  use ElephantInTheRoomWeb, :view

  def show_link_with_date(conn, post) do
    year = post.inserted_at.year
    month = post.inserted_at.month
    day = post.inserted_at.day

    post_path(conn, :public_show, year, month, day, post.slug)
  end
end
