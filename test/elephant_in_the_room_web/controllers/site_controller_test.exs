defmodule ElephantInTheRoomWeb.SiteControllerTest do
  use ElephantInTheRoomWeb.ConnCase

  alias ElephantInTheRoom.Sites
  alias ElephantInTheRoom.Auth.Guardian

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  def default_user() do
    %{
      :id => 1,
      "firstname" => "firstname",
      "lastname" => "lastname",
      "username" => "username",
      "password" => "password",
      "email" => "some@email.com",
      :role => %{:name => "admin"}
    }
  end

  def fixture(:site) do
    {:ok, site} = Sites.create_site(@create_attrs)
    site
  end

  describe "public show" do
    test "show default site", %{conn: conn} do
      conn = get(conn, site_path(conn, :show_default_site))
      assert html_response(conn, 200)
    end
  end

  describe "index" do
    test "lists all sites", %{conn: conn} do
      # Sign in
      conn =
        conn
        |> Guardian.Plug.sign_in(default_user())
        |> get(site_path(conn, :index))

      assert html_response(conn, 200)
    end
  end

  describe "new site" do
    test "renders form", %{conn: conn} do
      # Sign in
      conn =
        conn
        |> Guardian.Plug.sign_in(default_user())
        |> get(site_path(conn, :new))

      assert html_response(conn, 200) =~ "New Site"
    end
  end

  describe "create site" do
    test "redirects to show when data is valid", %{conn: conn} do
      # Sign In
      conn =
        conn
        |> Guardian.Plug.sign_in(default_user())
        |> post(site_path(conn, :create), site: @create_attrs)

      assert %{id: id} = redirected_params(conn)

      assert redirected_to(conn) == site_path(conn, :show, id)

      # Sign out and then sign in again with the same user
      conn =
        conn
        |> recycle()
        |> Guardian.Plug.sign_in(default_user())

      conn = get(conn, site_path(conn, :show, id))

      assert html_response(conn, 200) =~ "Show Site"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn =
        conn
        |> Guardian.Plug.sign_in(default_user())
        |> post(site_path(conn, :create), site: @invalid_attrs)

      assert html_response(conn, 200) =~ "New Site"
    end
  end

  describe "edit site" do
    setup [:create_site]

    test "renders form for editing chosen site", %{conn: conn, site: site} do
      conn =
        conn
        |> Guardian.Plug.sign_in(default_user())
        |> get(site_path(conn, :edit, site))

      assert html_response(conn, 200) =~ "Edit Site"
    end
  end

  describe "update site" do
    setup [:create_site]

    test "redirects when data is valid", %{conn: conn, site: site} do
      conn =
        conn
        |> Guardian.Plug.sign_in(default_user())
        |> put(site_path(conn, :update, site), site: @update_attrs)

      assert redirected_to(conn) == site_path(conn, :show, site)

      conn =
        conn
        |> recycle()
        |> Guardian.Plug.sign_in(default_user())
        |> get(site_path(conn, :show, site))

      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, site: site} do
      conn =
        conn
        |> Guardian.Plug.sign_in(default_user())
        |> put(site_path(conn, :update, site), site: @invalid_attrs)

      assert html_response(conn, 200) =~ "Edit Site"
    end
  end

  describe "delete site" do
    setup [:create_site]

    test "deletes chosen site", %{conn: conn, site: site} do
      conn =
        conn
        |> Guardian.Plug.sign_in(default_user())
        |> delete(site_path(conn, :delete, site))

      assert redirected_to(conn) == site_path(conn, :index)

      # Sign out and then Sign in again
      assert_error_sent(404, fn ->
        conn
        |> recycle()
        |> Guardian.Plug.sign_in(default_user())
        |> get(site_path(conn, :show, site))
      end)
    end
  end

  defp create_site(_) do
    site = fixture(:site)
    {:ok, site: site}
  end
end
