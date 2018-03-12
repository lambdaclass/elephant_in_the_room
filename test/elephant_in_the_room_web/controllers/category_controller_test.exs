defmodule ElephantInTheRoomWeb.CategoryControllerTest do
  use ElephantInTheRoomWeb.ConnCase

  alias ElephantInTheRoom.Sites

  @create_attrs %{site_id: 1, description: "some description", name: "some name"}
  @update_attrs %{description: "some updated description", name: "some updated name"}
  @invalid_attrs %{description: nil, name: nil}

  setup do
    {:ok, site} = Sites.create_site(%{name: "new site"})

    {:ok, site: site, conn: Phoenix.ConnTest.build_conn()}
  end

  def fixture(:category) do
    {:ok, category} = Sites.create_category(@create_attrs)
    category
  end

  describe "index" do
    test "lists all categories", %{conn: conn, site: site} do
      conn = get(conn, site_category_path(conn, :index, site))
      assert html_response(conn, 200) =~ "Listing Categories"
    end
  end

  describe "new category" do
    test "renders form", %{conn: conn, site: site} do
      conn = get(conn, site_category_path(conn, :new, site))
      assert html_response(conn, 200) =~ "New Category"
    end
  end

  describe "create category" do
    test "redirects to show when data is valid", %{conn: conn, site: site} do
      conn = post(conn, site_category_path(conn, :create, site), category: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == site_category_path(conn, :show, site, id)

      conn = get(conn, site_category_path(conn, :show, site, id))
      assert html_response(conn, 200) =~ "Show Category"
    end

    test "renders errors when data is invalid", %{conn: conn, site: site} do
      conn = post(conn, site_category_path(conn, :create, site), category: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Category"
    end
  end

  describe "edit category" do
    setup [:create_category]

    test "renders form for editing chosen category", %{conn: conn, category: category} do
      conn = get(conn, site_category_path(conn, :edit, category))
      assert html_response(conn, 200) =~ "Edit Category"
    end
  end

  describe "update category" do
    setup [:create_category]

    test "redirects when data is valid", %{conn: conn, category: category} do
      conn = put(conn, site_category_path(conn, :update, category), category: @update_attrs)
      assert redirected_to(conn) == site_category_path(conn, :show, category)

      conn = get(conn, site_category_path(conn, :show, category))
      assert html_response(conn, 200) =~ "some updated description"
    end

    test "renders errors when data is invalid", %{conn: conn, category: category} do
      conn = put(conn, site_category_path(conn, :update, category), category: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Category"
    end
  end

  describe "delete category" do
    setup [:create_category]

    test "deletes chosen category", %{conn: conn, category: category} do
      conn = delete(conn, site_category_path(conn, :delete, category))
      assert redirected_to(conn) == site_category_path(conn, :index)

      assert_error_sent(404, fn ->
        get(conn, site_category_path(conn, :show, category))
      end)
    end
  end

  defp create_category(_) do
    category = fixture(:category)
    {:ok, category: category}
  end
end
