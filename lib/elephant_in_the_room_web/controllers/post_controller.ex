defmodule ElephantInTheRoomWeb.PostController do
  use ElephantInTheRoomWeb, :controller
  alias ElephantInTheRoom.Post

  def creation_form(conn, _) do
    changeset = ElephantInTheRoom.Post.changeset()
    render conn, "creation_form.html", changeset: changeset
  end

  def create_new(conn, %{"post" => post_attr}) do
    changeset = Post.changeset(%Post{}, post_attr)
    
    if changeset.valid? do
      inspected_params= Kernel.inspect(post_attr)
      text conn, "#{inspected_params}"
    else
      changeset = %{changeset | action: :insert}
      put_flash conn, :error, "Invalid input"
      render conn,"creation_form.html", changeset: changeset
    end
    
  end  
end
