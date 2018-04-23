defmodule ElephantInTheRoomWeb.LayoutView do
  use ElephantInTheRoomWeb, :view
  alias ElephantInTheRoom.Sites
  alias ElephantInTheRoom.Auth
  alias Plug.Conn
  alias ElephantInTheRoomWeb.Router.Helpers
  alias ElephantInTheRoom.Auth.{User, Role}

  def get_nav_sites() do
    Sites.list_sites()
  end

  def get_categories(conn) do
    site = conn.assigns.site

    site.categories
    |> Enum.map(fn x ->
      {x.id, x.name}
    end)
  end

  def in_current_site(conn, site_id) do
    current_site = conn.assigns[:site]

    case current_site do
      nil -> false
      _ -> current_site.id == site_id
    end
  end

  def get_logged_user(conn) do
    case Auth.get_user(conn) do
      {:ok, %User{:role => %Role{:name => role}} = user} ->
        {:ok, user, String.to_atom(role)}

      {:error, _} = error ->
        error
    end
  end

  def get_site_path(conn) do
    case conn && conn.assigns[:site] do
      nil ->
        "/"

      _site ->
        Helpers.site_path(conn, :public_show)
    end
  end

  def current_site(conn) do
    conn.assigns[:site]
  end

  def put_site(conn, site) do
    Conn.put_resp_header(conn, "site_host", site.id)
    Conn.assign(conn, :site, site)
  end
end
