defmodule ElephantInTheRoomWeb.Plugs.DomainInspector do
  use Phoenix.Router
  alias Plug.Conn
  alias ElephantInTheRoom.{Repo, Sites}
  alias ElephantInTheRoom.Sites.Site
  alias ElephantInTheRoomWeb.Router.Helpers

  def set_site(%Conn{} = conn, _options) do
    if conn.host == "localhost" do
      # take this path if you are running elephant locally
      default_site = Sites.get_site!(1)

      conn
      |> Conn.assign(:site, default_site)
    else
      case Repo.get_by(Site, host: conn.host) do
        nil ->
          halt(conn)

        %Site{:id => site_id} = site ->
          site = Repo.preload(site, [:categories, :posts, :tags])

          conn =
            conn
            |> Map.put(:assigns, %{"site_id" => site.id})
            |> Conn.assign(:site, site)

          new_route = Helpers.site_path(conn, :public_show)

          conn
          |> Map.put(:request_path, new_route)
      end
    end
  end
end
