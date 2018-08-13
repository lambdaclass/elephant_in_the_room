defmodule ElephantInTheRoomWeb.Plugs.SetSite do
  import Phoenix.Controller, only: [redirect: 2]
  alias ElephantInTheRoom.{Repo, Sites}
  alias ElephantInTheRoom.Sites.Site
  alias ElephantInTheRoomWeb.Router.Helpers, as: Routes
  alias Plug.Conn

  def set_site(conn, _params) do
    case Repo.get_by(Site, host: conn.host) do
      nil ->
        conn
        |> redirect(to: Routes.login_path(conn, :login))
        |> Conn.halt()

      site ->
        site = Repo.preload(site, categories: [])

        new_conn = Conn.assign(conn, :site, site)

        meta = Sites.gen_og_meta_for_site(new_conn)

        new_conn
        |> Conn.assign(:meta, meta)
    end
  end
end
