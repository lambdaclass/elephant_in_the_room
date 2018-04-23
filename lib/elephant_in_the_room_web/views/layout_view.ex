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

      site ->
        Helpers.site_path(conn, :public_show, site)
    end
  end

  def current_site(conn) do
    conn.assigns[:site]
  end

  # def put_site(conn, site) do
  #   Conn.put_resp_header(conn, "site_host", site.id)
  #   Conn.assign(conn, :site, site)
  # end

  def show_site_link(site, conn) do
    if conn.host != "localhost" do
      "http://" <> site.host <> ":4000"
    else
      site_path(conn, :public_show, site.id)
    end
  end

  def show_category_link(category_id, site, conn) do
    if conn.host != "localhost" do
      category_path(conn, :public_show, category_id)
    else
      category_path(conn, :public_show, site.id, category_id)
    end
  end

  def show_nav_title() do
  end
end
