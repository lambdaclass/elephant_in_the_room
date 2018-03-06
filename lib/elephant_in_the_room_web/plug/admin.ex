defmodule ElephantInTheRoomWeb.Plugs.Admin do
  alias Plug.Conn
  alias ElephantInTheRoomWeb.Router.Helpers
  use Phoenix.Router

  def on_admin_page(%Conn{:private => private} = conn, _) do
    if Map.has_key?(private, :guardian_default_resource) && role_name(private) == "admin" do
      role_name = role_name(private)

      conn
      |> Conn.assign(:role, :admin)
      |> Conn.assign(:admin, true)
    else
      conn
      |> Phoenix.Controller.redirect(to: Helpers.page_path(conn, :index))
      |> halt()
    end
  end

  defp role_name(private_field) do
    private_field.guardian_default_resource.role.name
  end
end
