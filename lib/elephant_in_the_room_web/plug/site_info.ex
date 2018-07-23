defmodule ElephantInTheRoomWeb.Plugs.SiteInfo do
  alias Plug.Conn
  alias ElephantInTheRoom.Sites

  def load_site_info(%Conn{params: params} = conn, _) do
    site = Sites.get_site_by_name!(params["site_name"])
    Conn.assign(conn, :site, site)
  end

end
