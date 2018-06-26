defmodule ElephantInTheRoomWeb.LayoutView do
  use ElephantInTheRoomWeb, :view
  alias ElephantInTheRoom.{Sites, Site}
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

  def get_categories(%{assigns: %{site: %{categories: categories}}},
                     amount \\ 5) do
    categories
    |> Enum.map(&{&1.id, &1.name})
    |> Enum.split(amount)
  end
  def get_categories(_, _) do
    {[],[]}
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
          if conn.host != "localhost",
            do: site_path(conn, :public_show),
            else: local_site_path(conn, :public_show, site.id)
      end
    else
      site_path(conn, :public_index)
    end
  end

  def current_site(conn) do
    conn.assigns[:site]
  end

  def get_site_name(conn) do
    site = conn.assigns[:site]
    name = case site do
      nil -> "Elephant in the room"
      site -> site.name
    end
    [first | rest] = String.split(name, " ")
    second = Enum.join(rest, " ")
    {first, second}
  end

  def show_site_link(conn) do
    if conn.host != "localhost",
      do: "http://" <> conn.host <> ":4000",
      else: site_path(conn, :public_index)
  end

  def show_site_link(site, conn) do
    if conn.host != "localhost",
      do: "http://" <> site.host <> ":4000",
      else: local_site_path(conn, :public_show, site.id)
  end

  def show_category_link(conn, category_id, site) do
    if conn.host != "localhost",
      do: category_path(conn, :public_show, category_id),
      else: local_category_path(conn, :public_show, site.id, category_id)
  end
end
