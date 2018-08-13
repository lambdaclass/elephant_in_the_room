defmodule ElephantInTheRoomWeb.LoginController do
  use ElephantInTheRoomWeb, :controller
  alias ElephantInTheRoom.{Auth, Auth.User}

  def index(conn, _params) do
    changeset = Auth.change_user(%User{})

    user =
      case Auth.get_user(conn) do
        {:ok, %User{} = user} -> user
        {:error, reason} -> reason
      end

    render(conn, "login.html", changeset: changeset, user: user)
  end

  def login(conn, %{"user" => %{"username" => username, "password" => password}}) do
    Auth.authenticate_user(username, password)
    |> login_reply(conn)
  end

  defp login_reply({:error, _}, conn) do
    changeset = Auth.change_user(%User{})
    new_conn = put_flash(conn, :error, "Wrong user or password. Try again.")

    render(new_conn, "login.html", changeset: changeset, user: :login_failed)
  end

  defp login_reply({:ok, user}, conn) do
    {:ok, conn, user} = Auth.sign_in_user(conn, user)

    if user.role.name == "admin" do
      redirect(conn, to: "/admin", user: user)
    else
      redirect(conn, to: "/", user: user)
    end
  end

  def logout(conn, _) do
    conn
    |> Auth.sign_out_user()
    |> redirect(to: login_path(conn, :login))
  end
end
