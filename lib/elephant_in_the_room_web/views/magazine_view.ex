defmodule ElephantInTheRoomWeb.MagazineView do
  use ElephantInTheRoomWeb, :view

  def image_link(img_uuid) do
    "/images/#{img_uuid}"
  end

  def show_link_with_date(conn, magazine, post) do
    year = post.inserted_at.year
    month = post.inserted_at.month
    day = post.inserted_at.day

    URI.encode(magazine_post_path(conn, :public_show, magazine.title, year, month, day, post.slug))
  end
end
