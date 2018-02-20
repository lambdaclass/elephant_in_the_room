defmodule ElephantInTheRoomWeb.CategoryController do
  use ElephantInTheRoomWeb, :controller

  alias ElephantInTheRoom.{Sites, Repo}
  alias ElephantInTheRoom.Sites.{Category, Site}
  plug(:assign_site)

  def action(conn, _) do
    site = Sites.get_site!(conn.params["site_id"])
    args = [conn, conn.params, site]
    apply(__MODULE__, action_name(conn), args)
  end

  def index(conn, _params, site) do
    categories = Sites.list_categories(site)
    render(conn, "index.html", site: site, categories: categories)
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
    category = Sites.get_category!(site, id)

    render(conn, "show.html", site: site, category: category)
  end

  def edit(conn, %{"id" => id}, site) do
    category = Sites.get_category!(site, id)
    changeset = Sites.change_category(category)
    render(conn, "edit.html", category: category, changeset: changeset, site: site)
  end

  def update(conn, %{"id" => id, "category" => category_params}, site) do
    category = Sites.get_category!(id)

    case Sites.update_category(category, category_params) do
      {:ok, category} ->
        conn
        |> put_flash(:info, "Category updated successfully.")
        |> redirect(to: site_category_path(conn, :show, category, site))

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

  defp assign_site(conn, _opts) do
    case conn.params do
      %{"site_id" => site_id} ->
        site = Repo.get(Site, site_id)
        assign(conn, :site, site)

      _ ->
        conn
    end
  end
end
