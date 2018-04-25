defmodule ElephantInTheRoomWeb.Plugs.SetSite do
  alias ElephantInTheRoom.Repo
  alias ElephantInTheRoom.Sites.Site

  def set_site(conn, params) do
    if conn.host != "localhost" do
      case Repo.get_by(Site, host: conn.host) do
        nil ->
          conn

        site ->
          site = site |> Repo.preload([:categories, :posts, :tags])
          Map.put(conn, :site, site)
      end
    else
      conn
    end
  end
end
