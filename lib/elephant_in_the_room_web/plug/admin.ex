defmodule ElephantInTheRoomWeb.Plugs.Admin do
  alias Plug.Conn

  def on_admin_page(%Conn{} = conn, _) do
    Conn.assign conn, :admin, true
  end
  
end
