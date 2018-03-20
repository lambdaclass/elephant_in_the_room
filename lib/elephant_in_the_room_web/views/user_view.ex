defmodule ElephantInTheRoomWeb.UserView do
  use ElephantInTheRoomWeb, :view
  import ElephantInTheRoomWeb.Utils.ViewUtils
  alias ElephantInTheRoom.Auth

  def get_roles() do
    Auth.list_roles()
    |> Enum.map(fn role -> {role.name, role.id} end)
  end

  def get_rolename(role) do
    role.name
  end
end
