defmodule ElephantInTheRoomWeb.LayoutView do
  use ElephantInTheRoomWeb, :view
  alias ElephantInTheRoom.Sites
  alias ElephantInTheRoom.Auth
  alias ElephantInTheRoom.Auth.{User, Role}

  def get_nav_sites(conn) do
    if conn.host != "localhost" do
      Sites.list_sites()
      |> Enum.filter(fn s -> s.host != "localhost" end)
    else
      Sites.list_sites()
    end
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
    if Map.has_key?(conn.assigns, :site) do
      case conn && conn.assigns.site do
        nil ->
          "/"

        site ->
          choose_route(conn, fn -> site_path(conn, :public_show) end, fn ->
            local_site_path(conn, :public_show, site.id)
          end)
      end
    else
      site_path(conn, :public_index)
    end
  end

  def current_site(conn) do
    conn.assigns[:site]
  end

  def show_site_link(conn) do
    choose_route(conn, fn -> "http://" <> conn.host <> ":4000" end, fn ->
      site_path(conn, :public_index)
    end)
  end

  def show_site_link(site, conn) do
    choose_route(conn, fn -> "http://" <> site.host <> ":4000" end, fn ->
      local_site_path(conn, :public_show, site.id)
    end)
  end

  def show_category_link(conn, category_id, site) do
    route1 = fn -> category_path(conn, :public_show, category_id) end
    route2 = fn -> local_category_path(conn, :public_show, site.id, category_id) end
    choose_route(conn, route1, route2)
  end
end
