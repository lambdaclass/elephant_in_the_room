defmodule ElephantInTheRoomWeb.LayoutView do
  use ElephantInTheRoomWeb, :view
  alias ElephantInTheRoom.{Sites, Sites.Site}
  alias ElephantInTheRoom.Auth
  alias ElephantInTheRoom.Auth.{User, Role}

  def get_categories(assigns, amount \\ 5)

  def get_categories(%{assigns: %{site: %{categories: categories}}}, amount) do
    categories
    |> Enum.map(&{&1.id, &1.name})
    |> Enum.split(amount)
  end

  def get_categories(_, _) do
    {[], []}
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

  def get_logger_user_name!(conn) do
    case get_logged_user(conn) do
      {_error, reason} -> raise "no user name found: #{reason}"
      {:ok, user, _} -> user.username
    end
  end

  def get_site_path(conn) do
    if Map.has_key?(conn.assigns, :site) do
      case conn && conn.assigns.site do
        nil ->
          login_path(conn, :login)

        _site ->
          site_path(conn, :public_show)
      end
    end
  end

  def current_site(conn) do
    conn.assigns[:site]
  end

  def get_site_name(conn) do
    site = conn.assigns[:site]

    name =
      case site do
        nil -> "Elephant in the room"
        site -> site.name
      end

    [first | rest] = String.split(name, " ")
    second = Enum.join(rest, " ")
    {first, second}
  end

  def show_site_link(%Site{} = site, conn) do
    "#{to_string(conn.scheme)}://#{site.host}:#{to_string(conn.port)}"
  end

  def show_site_link(conn), do: "http://" <> conn.host

  def show_category_link(conn, category_id) do
    category_path(conn, :public_show, category_id)
  end
end
