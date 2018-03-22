defmodule ElephantInTheRoomWeb.FakeSession do
  alias Phoenix.ConnTest
  alias ElephantInTheRoom.Auth.Guardian

  @default_user %{
    :id => 1,
    "firstname" => "firstname",
    "lastname" => "lastname",
    "username" => "username",
    "password" => "password",
    "email" => "some@email.com",
    :role => %{:name => "admin"}
  }

  def sign_in(conn, user \\ @default_user) do
    Guardian.Plug.sign_in(conn, user)
  end

  def sign_out(conn) do
    ConnTest.recycle(conn)
  end

  def sign_out_then_sign_in(conn) do
    conn
    |> sign_out()
    |> sign_in()
  end
end
