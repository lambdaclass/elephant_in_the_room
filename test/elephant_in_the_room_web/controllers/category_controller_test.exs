defmodule ElephantInTheRoomWeb.CategoryControllerTest do
  use ElephantInTheRoomWeb.ConnCase, admin: true

  alias ElephantInTheRoom.Sites
  alias ElephantInTheRoom.Sites.Site
  alias ElephantInTheRoom.Sites.Category

  describe "create category" do
    test "redirects to show when data is valid", %{conn: conn, site: site} do
      conn =
        post(
          conn,
          site_category_path(conn, :create, site.id),
          category: category(site, "name1", "des1")
        )
    end
  end

  def category(%Site{} = site, name, des) do
    %Category{name: name, description: des, site_id: site.id}
  end
end
