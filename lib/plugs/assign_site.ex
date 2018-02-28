defmodule ElephantInTheRoom.Plugs.AssignSite do
  import Plug.Conn
  import Phoenix.Controller

  alias ElephantInTheRoom.Repo
  alias ElephantInTheRoom.Sites.Site

  def init(options), do: options

  def call(conn, _opts) do
    case conn.params do
      %{"site_id" => site_id} ->
        site = Repo.get(Site, site_id)
        assign(conn, :site, site)

      _ ->
        conn
    end
  end
end
