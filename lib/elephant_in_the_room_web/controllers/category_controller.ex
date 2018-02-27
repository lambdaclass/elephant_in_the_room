defmodule ElephantInTheRoomWeb.CategoryController do
  use ElephantInTheRoomWeb, :controller

  alias ElephantInTheRoom.Sites
  alias ElephantInTheRoom.Sites.Category

  def action(conn, _params) do
    site = Sites.get_site!(conn.params["site_id"])
    args = [conn, conn.params, site]
    apply(__MODULE__, action_name(conn), args)
  end

  def index(conn, _params, site) do
    categories = Sites.list_categories(site)
    render(conn, "index.html", categories: categories, site: site)
  end

  def new(conn, _params, site) do
    changeset =
      %Category{site_id: site.id}
      |> Sites.change_category()

    render(conn, "new.html", changeset: changeset, site: site)
  end

  def create(conn, %{"category" => category_params}, site) do
    case Sites.create_category(site, category_params) do
      {:ok, category} ->
        conn
        |> put_flash(:info, "Category created successfully.")
        |> redirect(to: site_category_path(conn, :show, site, category))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, site: site)
    end
  end

  def show(conn, %{"id" => id}, site) do
    category = Sites.get_category!(id)

    render(conn, "show.html", category: category, site: site)
  end

  def edit(conn, %{"id" => id}, site) do
    category = Sites.get_category!(site, id)
    changeset = Sites.change_category(category)
    render(conn, "edit.html", site: site, category: category, changeset: changeset)
  end

  def update(conn, %{"id" => id, "category" => category_params}, site) do
    category = Sites.get_category!(id)

    case Sites.update_category(category, category_params) do
      {:ok, category} ->
        conn
        |> put_flash(:info, "Category updated successfully.")
        |> redirect(to: site_category_path(conn, :show, site, category))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", category: category, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}, site) do
    category = Sites.get_category!(id)
    {:ok, _category} = Sites.delete_category(category)

    conn
    |> put_flash(:info, "Category deleted successfully.")
    |> redirect(to: site_category_path(conn, :index, site))
  end
end
