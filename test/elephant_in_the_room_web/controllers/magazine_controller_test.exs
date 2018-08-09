defmodule ElephantInTheRoomWeb.MagazineControllerTest do
  use ElephantInTheRoomWeb.ConnCase

  alias ElephantInTheRoom.Sites

  @create_attrs %{cover: "some cover", description: "some description", title: "some title"}
  @update_attrs %{cover: "some updated cover", description: "some updated description", title: "some updated title"}
  @invalid_attrs %{cover: nil, description: nil, title: nil}

  def fixture(:magazine) do
    {:ok, magazine} = Sites.create_magazine(@create_attrs)
    magazine
  end

  describe "index" do
    test "lists all magazines", %{conn: conn} do
      conn = get conn, magazine_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Magazines"
    end
  end

  describe "new magazine" do
    test "renders form", %{conn: conn} do
      conn = get conn, magazine_path(conn, :new)
      assert html_response(conn, 200) =~ "New Magazine"
    end
  end

  describe "create magazine" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, magazine_path(conn, :create), magazine: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == magazine_path(conn, :show, id)

      conn = get conn, magazine_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Magazine"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, magazine_path(conn, :create), magazine: @invalid_attrs
      assert html_response(conn, 200) =~ "New Magazine"
    end
  end

  describe "edit magazine" do
    setup [:create_magazine]

    test "renders form for editing chosen magazine", %{conn: conn, magazine: magazine} do
      conn = get conn, magazine_path(conn, :edit, magazine)
      assert html_response(conn, 200) =~ "Edit Magazine"
    end
  end

  describe "update magazine" do
    setup [:create_magazine]

    test "redirects when data is valid", %{conn: conn, magazine: magazine} do
      conn = put conn, magazine_path(conn, :update, magazine), magazine: @update_attrs
      assert redirected_to(conn) == magazine_path(conn, :show, magazine)

      conn = get conn, magazine_path(conn, :show, magazine)
      assert html_response(conn, 200) =~ "some updated cover"
    end

    test "renders errors when data is invalid", %{conn: conn, magazine: magazine} do
      conn = put conn, magazine_path(conn, :update, magazine), magazine: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Magazine"
    end
  end

  describe "delete magazine" do
    setup [:create_magazine]

    test "deletes chosen magazine", %{conn: conn, magazine: magazine} do
      conn = delete conn, magazine_path(conn, :delete, magazine)
      assert redirected_to(conn) == magazine_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, magazine_path(conn, :show, magazine)
      end
    end
  end

  defp create_magazine(_) do
    magazine = fixture(:magazine)
    {:ok, magazine: magazine}
  end
end
