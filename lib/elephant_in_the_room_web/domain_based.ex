defmodule ElephantInTheRoomWeb.DomainBased do
  use ElephantInTheRoomWeb, :view
  alias Plug.Conn
  
  def is_localhost(%Conn{host: host}) do
    host == "localhost"
  end

  def is_not_localhost(conn), do: !is_localhost(conn)

  def get_site_id(%Conn{} = conn, params) do 
    id = if !is_localhost(conn), 
      do: conn.assigns.site.id,
      else: params["id"]
    case id do
      nil -> {:error, :no_site_id}
      id -> {:ok, id}
    end
  end

  def get_post_public_show_path(conn, post, site) do
    year = post.inserted_at.year
    month = post.inserted_at.month
    day = post.inserted_at.day
    site_id =
      case site do
        nil -> post.site.id
        _ -> site.id
      end

    if is_not_localhost(conn),
      do: post_path(conn, :public_show, year, month, day, post.slug),
      else: local_post_path(conn, :public_show, site_id, year, month, day, post.slug)
  end

end