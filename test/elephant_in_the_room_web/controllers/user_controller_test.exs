defmodule ElephantInTheRoomWeb.UserControllerTest do
  use ElephantInTheRoomWeb.ConnCase
  alias ElephantInTheRoom.{Auth, Auth.User}
  alias ElephantInTheRoom.Repo
  alias ElephantInTheRoomWeb.FakeSession

  @create_attrs %{
    email: "some@email.com",
    firstname: "some firstname",
    lastname: "some lastname",
    password: "some_password",
    username: "some_username"
  }
  @update_attrs %{
    email: "some_updated@email.com",
    firstname: "some updated firstname",
    lastname: "some updated lastname",
    password: "some_updated_password",
    username: "some_updated_username"
  }
  @invalid_attrs %{
    email: nil,
    firstname: nil,
    lastname: nil,
    password: nil,
    username: nil,
    role_id: nil
  }

  def fixture(:user) do
    {:ok, role} = Auth.create_role(%{name: "admin"})
    attrs = Enum.into(@create_attrs, %{role_id: role.id})
    {:ok, user} = Auth.create_user(attrs)
    user
  end

  describe "index" do
    test "lists all users", %{conn: conn} do
      conn =
        conn
        |> FakeSession.sign_in()
        |> get(user_path(conn, :index))

      assert html_response(conn, 200) =~ "Listing Users"
    end
  end

  describe "new user" do
    test "renders form", %{conn: conn} do
      user = fixture(:user)

      conn =
        conn
        |> FakeSession.sign_in(user)
        |> get(user_path(conn, :new))

      assert html_response(conn, 200)
    end
  end

  describe "create user" do
    test "redirects to show when data is valid", %{conn: conn} do
      {:ok, role} = Auth.create_role(%{name: "editor"})
      attrs = Enum.into(@create_attrs, %{role_id: role.id})

      conn =
        conn
        |> FakeSession.sign_in()
        |> post(user_path(conn, :create), user: attrs)

      assert redirected_to(conn) == login_path(conn, :index)

      created_user = Repo.get_by(User, username: @create_attrs.username)

      conn =
        conn
        |> FakeSession.sign_out_then_sign_in()
        |> get(user_path(conn, :show, created_user.id))

      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      user = fixture(:user)

      conn =
        conn
        |> FakeSession.sign_in(user)
        |> post(user_path(conn, :create), user: @invalid_attrs)

      assert html_response(conn, 200)
    end
  end

  describe "edit user" do
    setup [:create_user]

    test "renders form for editing chosen user", %{conn: conn, user: user} do
      conn =
        conn
        |> FakeSession.sign_in()
        |> get(user_path(conn, :edit, user))

      assert html_response(conn, 200) =~ "Edit User"
    end
  end

  describe "update user" do
    setup [:create_user]

    test "redirects when data is valid", %{conn: conn, user: user} do
      conn =
        conn
        |> FakeSession.sign_in()
        |> put(user_path(conn, :update, user), user: @update_attrs)

      assert redirected_to(conn) == user_path(conn, :show, user)

      conn =
        conn
        |> FakeSession.sign_out_then_sign_in()
        |> get(user_path(conn, :show, user))

      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn =
        conn
        |> FakeSession.sign_in()
        |> put(user_path(conn, :update, user), user: @invalid_attrs)

      assert html_response(conn, 200) =~ "Edit User"
    end
  end

  describe "delete user" do
    setup [:create_user]

    test "deletes chosen user", %{conn: conn, user: user} do
      conn =
        conn
        |> FakeSession.sign_in()
        |> delete(user_path(conn, :delete, user))

      assert redirected_to(conn) == user_path(conn, :index)

      assert_error_sent(404, fn ->
        conn
        |> FakeSession.sign_out_then_sign_in()
        |> get(user_path(conn, :show, user))
      end)
    end
  end

  defp create_user(_) do
    user = fixture(:user)
    {:ok, user: user}
  end
end
