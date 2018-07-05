defmodule ElephantInTheRoomWeb.DomainBased do
  alias Plug.Conn
  
  def is_localhost(%Conn{host: host}) do
    host == "localhost"
  end

  def get_site_id(%Conn{} = conn, params) do 
    id = if !is_localhost(conn), 
      do: conn.assigns.site.id,
      else: params["id"]
    case id do
      nil -> {:error, :no_site_id}
      id -> {:ok, id}
    end
  end

end