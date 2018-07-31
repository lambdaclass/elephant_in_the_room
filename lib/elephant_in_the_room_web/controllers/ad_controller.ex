defmodule ElephantInTheRoomWeb.AdController do
  use ElephantInTheRoomWeb, :controller
  import ElephantInTheRoomWeb.Utils.Utils, only: [get_page: 1]
  alias ElephantInTheRoom.Sites.Ad

  def index(conn, params) do
    site = conn.assigns.site
    page = get_page(params)
    ads = Ad.get(site, amount: 10, page: page)
    render(conn, "index.html",
      ads: ads,
      bread_crumb: [:sites, site, :ads])
  end

end
