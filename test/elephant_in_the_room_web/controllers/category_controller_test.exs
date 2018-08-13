defmodule ElephantInTheRoomWeb.CategoryControllerTest do
  use ElephantInTheRoomWeb.ConnCase
  alias ElephantInTheRoom.Sites
  alias ElephantInTheRoomWeb.FakeSession

  @create_attrs %{"name" => "some name", "description" => "some description"}
  @update_attrs %{"name" => "some updated name", "description" => "some description"}
  @invalid_attrs %{"name" => nil, "description" => nil}

  def fixture(:category, site \\ %{}) do
    {:ok, category} = Sites.create_category(site, @create_attrs)
    category
  end

  describe "index" do
    test "lists all categories", %{conn: conn, site: site} do
      conn =
        conn
        |> FakeSession.sign_in()
        |> get(site_category_path(conn, :index, site))

      assert html_response(conn, 200) =~ "Categories"
    end
  end

  describe "new category" do
    test "renders form", %{conn: conn, site: site} do
      conn =
        conn
        |> FakeSession.sign_in()
        |> get(site_category_path(conn, :new, site))

      assert html_response(conn, 200) =~ "New Category"
    end
  end

  describe "create category" do
    test "redirects to show when data is valid", %{conn: conn, site: site} do
      conn =
        conn
        |> FakeSession.sign_in()
        |> post(site_category_path(conn, :create, site), category: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == site_category_path(conn, :show, site, id)

      conn =
        conn
        |> FakeSession.sign_out_then_sign_in()
        |> get(site_category_path(conn, :show, site, id))

      assert html_response(conn, 200) =~ "Show Category"
    end

    test "renders errors when data is invalid", %{conn: conn, site: site} do
      conn =
        conn
        |> FakeSession.sign_in()
        |> post(site_category_path(conn, :create, site), category: @invalid_attrs)

      assert html_response(conn, 200) =~ "New Category"
    end
  end

  describe "edit category" do
    setup [:create_category]

    test "renders form for editing chosen category", %{conn: conn, site: site, category: category} do
      conn =
        conn
        |> FakeSession.sign_in()
        |> get(site_category_path(conn, :edit, site, category))

      assert html_response(conn, 200) =~ "Edit Category"
    end
  end

  describe "update category" do
    setup [:create_category]

    test "redirects when data is valid", %{conn: conn, site: site, category: category} do
      conn =
        conn
        |> FakeSession.sign_in()
        |> put(site_category_path(conn, :update, site, category), category: @update_attrs)

      assert redirected_to(conn) == site_category_path(conn, :show, site, category)

      conn =
        conn
        |> FakeSession.sign_out_then_sign_in()
        |> get(site_category_path(conn, :show, site, category))

      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, site: site, category: category} do
      conn =
        conn
        |> FakeSession.sign_in()
        |> put(site_category_path(conn, :update, site, category), category: @invalid_attrs)

      assert html_response(conn, 200) =~ "Edit Category"
    end
  end

  describe "delete category" do
    setup [:create_category]

    test "deletes chosen category", %{conn: conn, site: site, category: category} do
      conn =
        conn
        |> FakeSession.sign_in()
        |> delete(site_category_path(conn, :delete, site, category))

      assert redirected_to(conn) == site_category_path(conn, :index, site)

      assert_error_sent(404, fn ->
        conn
        |> FakeSession.sign_out_then_sign_in()
        |> get(site_category_path(conn, :show, category, site))
      end)
    end
  end

  defp create_category(_) do
    {:ok, site} = Sites.create_site(%{name: "test site"})
    category = fixture(:category, site)
    {:ok, category: category}
  end
end
