defmodule ElephantInTheRoomWeb.PostController do
  use ElephantInTheRoomWeb, :controller

  def creation_form(conn, _params) do
    changeset = ElephantInTheRoom.Post.changeset()
    render conn, "creation_form.html", changeset: changeset
  end

  def create_new(conn, params) do
    inspected_params= Kernel.inspect(params)
    text conn, "#{inspected_params}"
  end
  
end
