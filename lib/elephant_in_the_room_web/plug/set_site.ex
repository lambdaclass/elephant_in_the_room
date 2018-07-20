defmodule ElephantInTheRoomWeb.Plugs.SetSite do
  alias ElephantInTheRoom.Repo
  alias ElephantInTheRoom.Sites.Site
  alias Plug.Conn
  alias ElephantInTheRoomWeb.Router.Helpers, as: Routes
  import Phoenix.Controller, only: [redirect: 2]

  def set_site(conn, _params) do
    case Repo.get_by(Site, host: conn.host) do
      nil ->
        conn
        |> redirect(to: Routes.login_path(conn, :login))
        |> Conn.halt()

      site -> Conn.assign(conn, :site, site)
    end
  end
end
