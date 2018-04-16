defmodule ElephantInTheRoomWeb.Plugs.DomainInspector do
  alias Plug.Conn
  alias ElephantInTheRoom.Repo
  alias ElephantInTheRoom.Sites.Site
  alias ElephantInTheRoomWeb.Router.Helpers
  use Phoenix.Router

  def inspectConn(%Conn{} = conn, _options) do
    case Repo.get_by(Site, url: conn.host) do
      nil ->
        halt(conn)

      %Site{:id => site_id} = site ->
        conn
        |> Conn.assign(:request_path, Helpers.site_path(conn, :public_show, site))
        |> Conn.assign(:assigns, %{site: site})
    end
  end
end
