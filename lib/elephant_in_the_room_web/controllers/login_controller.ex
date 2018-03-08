defmodule ElephantInTheRoomWeb.LoginController do
  use ElephantInTheRoomWeb, :controller

  alias ElephantInTheRoom.Auth
  alias ElephantInTheRoom.Auth.User
  alias ElephantInTheRoom.Auth.Guardian

  def index(conn, _params) do
    changeset = Auth.change_user(%User{})
    user = case Guardian.Plug.current_resource(conn) do
             %User{} = user -> user
             nil -> :no_user
           end

    render(conn, "login.html", changeset: changeset, user: user)
  end

  def login(conn, %{"user" => %{"username" => username, "password" => password}}) do
    Auth.authenticate_user(username, password)
    |> login_reply(conn)
  end

  defp login_reply({:error, error}, conn) do
    render(conn, "login.html", user: :login_failed)
  end

  defp login_reply({:ok, user}, conn) do
    conn
    |> Guardian.Plug.sign_in(user)
    |> render("login.html", user: user)
  end

  def logout(conn, _) do
    conn
    |> Guardian.Plug.sign_out()
    |> redirect(to: login_path(conn, :login))
  end

  def secret(conn, _params) do
    render(conn, "secret.html")
  end
end
