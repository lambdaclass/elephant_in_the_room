defmodule ElephantInTheRoomWeb.UserView do
  use ElephantInTheRoomWeb, :view

  alias ElephantInTheRoom.Auth

  def get_roles() do
    Auth.list_roles()
    |> Enum.map(fn role -> {role.name, role.id} end)
  end
end
