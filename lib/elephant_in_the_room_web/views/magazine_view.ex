defmodule ElephantInTheRoomWeb.MagazineView do
  use ElephantInTheRoomWeb, :view

  def image_link(img_uuid) do
    "/images/#{img_uuid}"
  end
end
