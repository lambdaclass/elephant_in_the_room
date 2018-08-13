defmodule ElephantInTheRoomWeb.TagControllerTest do
  use ElephantInTheRoomWeb.ConnCase
  alias ElephantInTheRoom.Sites
  alias ElephantInTheRoomWeb.FakeSession

  @create_attrs %{"name" => "some name"}
  @update_attrs %{"name" => "some updated name"}
  @invalid_attrs %{"name" => nil}

  def fixture(:tag, site \\ %{}) do
    {:ok, tag} = Sites.create_tag(site, @create_attrs)
    tag
  end

  describe "index" do
    test "lists all tags", %{conn: conn, site: site} do
      conn =
        conn
        |> FakeSession.sign_in()
        |> get(site_tag_path(conn, :index, site))

      assert html_response(conn, 200) =~ "Listing Tags"
    end
  end

  describe "new tag" do
    test "renders form", %{conn: conn, site: site} do
      conn =
        conn
        |> FakeSession.sign_in()
        |> get(site_tag_path(conn, :new, site))

      assert html_response(conn, 200) =~ "New Tag"
    end
  end

  describe "create tag" do
    test "redirects to show when data is valid", %{conn: conn, site: site} do
      conn =
        conn
        |> FakeSession.sign_in()
        |> post(site_tag_path(conn, :create, site), tag: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == site_tag_path(conn, :show, site, id)

      conn =
        conn
        |> FakeSession.sign_out_then_sign_in()
        |> get(site_tag_path(conn, :show, site, id))

      assert html_response(conn, 200) =~ "Show Tag"
    end

    test "renders errors when data is invalid", %{conn: conn, site: site} do
      conn =
        conn
        |> FakeSession.sign_in()
        |> post(site_tag_path(conn, :create, site), tag: @invalid_attrs)

      assert html_response(conn, 200) =~ "New Tag"
    end
  end

  describe "edit tag" do
    setup [:create_tag]

    test "renders form for editing chosen tag", %{conn: conn, site: site, tag: tag} do
      conn =
        conn
        |> FakeSession.sign_in()
        |> get(site_tag_path(conn, :edit, site, tag))

      assert html_response(conn, 200) =~ "Edit Tag"
    end
  end

  describe "update tag" do
    setup [:create_tag]

    test "redirects when data is valid", %{conn: conn, site: site, tag: tag} do
      conn =
        conn
        |> FakeSession.sign_in()
        |> put(site_tag_path(conn, :update, site, tag), tag: @update_attrs)

      assert redirected_to(conn) == site_tag_path(conn, :show, site, tag)

      conn =
        conn
        |> FakeSession.sign_out_then_sign_in()
        |> get(site_tag_path(conn, :show, site, tag))

      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, site: site, tag: tag} do
      conn =
        conn
        |> FakeSession.sign_in()
        |> put(site_tag_path(conn, :update, site, tag), tag: @invalid_attrs)

      assert html_response(conn, 200) =~ "Edit Tag"
    end
  end

  describe "delete tag" do
    setup [:create_tag]

    test "deletes chosen tag", %{conn: conn, site: site, tag: tag} do
      conn =
        conn
        |> FakeSession.sign_in()
        |> delete(site_tag_path(conn, :delete, site, tag))

      assert redirected_to(conn) == site_tag_path(conn, :index, site)

      assert_error_sent(404, fn ->
        conn
        |> FakeSession.sign_out_then_sign_in()
        |> get(site_tag_path(conn, :show, tag, site))
      end)
    end
  end

  defp create_tag(_) do
    {:ok, site} = Sites.create_site(%{name: "test site"})
    tag = fixture(:tag, site)
    {:ok, tag: tag}
  end
end
