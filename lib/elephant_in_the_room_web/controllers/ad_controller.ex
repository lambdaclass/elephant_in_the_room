defmodule ElephantInTheRoomWeb.AdController do
  use ElephantInTheRoomWeb, :controller

  def index(conn, _params) do
    site = conn.assigns.site
    render(conn, "index.html",
      ads: [],
      bread_crumb: [:sites, site, :ads])
  end

end
