defmodule ElephantInTheRoomWeb.PostControllerTest do
  use ElephantInTheRoomWeb.ConnCase
  alias ElephantInTheRoomWeb.FakeSession
  alias ElephantInTheRoom.Sites

  @create_attrs %{
    "title" => "some title",
    "abstract" => "some abstract",
    "content" => "some content",
    "slug" => "some-slug",
    "image" => "some image",
    "categories" => [],
    "tags" => ""
  }
  @update_attrs %{
    "title" => "some updated title",
    "abstract" => "some updated abstract",
    "content" => "some content",
    "slug" => "some-slug",
    "image" => "some image",
    "categories" => [],
    "tags" => ""
  }
  @invalid_attrs %{
    "title" => nil,
    "slug" => nil,
    "abstract" => nil,
    "content" => nil,
    "image" => nil,
    "categories" => nil,
    "tags" => nil
  }

  def fixture(:post, site \\ %{}) do
    {:ok, post} = Sites.create_post(site, @create_attrs)
    post
  end

  describe "index" do
    test "lists all posts", %{conn: conn, site: site} do
      conn =
        conn
        |> FakeSession.sign_in()
        |> get(site_post_path(conn, :index, site))

      assert html_response(conn, 200) =~ "Listing Posts"
    end
  end

  describe "new post" do
    test "renders form", %{conn: conn, site: site} do
      conn =
        conn
        |> FakeSession.sign_in()
        |> get(site_post_path(conn, :new, site))

      assert html_response(conn, 200) =~ "New Post"
    end
  end

  describe "create post" do
    test "redirects to show when data is valid", %{conn: conn, site: site} do
      conn =
        conn
        |> FakeSession.sign_in()
        |> post(site_post_path(conn, :create, site), post: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == site_post_path(conn, :show, site, id)

      conn =
        conn
        |> FakeSession.sign_out_then_sign_in()
        |> get(site_post_path(conn, :show, site, id))

      assert html_response(conn, 200) =~ "Show Post"
    end

    test "renders errors when data is invalid", %{conn: conn, site: site} do
      conn =
        conn
        |> FakeSession.sign_in()
        |> post(site_post_path(conn, :create, site), post: @invalid_attrs)

      assert html_response(conn, 200) =~ "New Post"
    end
  end

  describe "edit post" do
    setup [:create_post]

    test "renders form for editing chosen post", %{conn: conn, site: site, post: post} do
      conn =
        conn
        |> FakeSession.sign_in()
        |> get(site_post_path(conn, :edit, site, post))

      assert html_response(conn, 200) =~ "Edit Post"
    end
  end

  describe "update post" do
    setup [:create_post]

    test "redirects when data is valid", %{conn: conn, site: site, post: post} do
      conn =
        conn
        |> FakeSession.sign_in()
        |> put(site_post_path(conn, :update, site, post), post: @update_attrs)

      assert redirected_to(conn) == site_post_path(conn, :show, site, post)

      conn =
        conn
        |> FakeSession.sign_out_then_sign_in()
        |> get(site_post_path(conn, :show, site, post))

      assert html_response(conn, 200) =~ "some updated title"
    end

    test "renders errors when data is invalid", %{conn: conn, site: site, post: post} do
      conn =
        conn
        |> FakeSession.sign_in()
        |> put(site_post_path(conn, :update, site, post), post: @invalid_attrs)

      assert html_response(conn, 200) =~ "Edit Post"
    end
  end

  describe "delete post" do
    setup [:create_post]

    test "deletes chosen post", %{conn: conn, site: site, post: post} do
      conn =
        conn
        |> FakeSession.sign_in()
        |> delete(site_post_path(conn, :delete, site, post))

      assert redirected_to(conn) == site_post_path(conn, :index, site)

      assert_error_sent(404, fn ->
        conn
        |> FakeSession.sign_out_then_sign_in()
        |> get(site_post_path(conn, :show, post, site))
      end)
    end
  end

  defp create_post(_) do
    {:ok, site} = Sites.create_site(%{name: "test site"})
    post = fixture(:post, site)
    {:ok, post: post}
  end
end
