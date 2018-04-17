defmodule ElephantInTheRoomWeb.Plugs.DomainInspector do
  use Phoenix.Router
  alias Plug.Conn
  alias ElephantInTheRoom.Repo
  alias ElephantInTheRoom.Sites.Site
  alias ElephantInTheRoomWeb.Router.Helpers
  alias ElephantInTheRoom.Repo

  def inspectConn(%Conn{} = conn, _options) do
    case Repo.get_by(Site, host: conn.host) do
      nil ->
        halt(conn)

      %Site{:id => site_id} = site ->
        site = Repo.preload(site, [:categories, :posts, :tags])

        conn =
          conn
          |> Conn.assign(:assigns, %{"site_id" => site.id})
          |> Conn.assign(:site, site)

        new_route = Helpers.site_path(conn, :public_show)

        conn =
          conn
          |> Conn.assign(:request_path, new_route)

        conn
    end
  end
end
