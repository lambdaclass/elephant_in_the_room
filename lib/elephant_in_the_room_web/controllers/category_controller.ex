defmodule ElephantInTheRoomWeb.CategoryController do
  use ElephantInTheRoomWeb, :controller
  alias ElephantInTheRoom.{Repo, Sites, Sites.Category}
  import Ecto.Query

  def index(%{assigns: %{site: site}} = conn, params) do
    page =
      case params do
        %{"page" => page_number} ->
          Category
          |> where([c], c.site_id == ^site.id)
          |> Repo.paginate(page: page_number)

        %{} ->
          Category
          |> where([c], c.site_id == ^site.id)
          |> Repo.paginate(page: 1)
      end

    render(
      conn,
      "index.html",
      categories: page.entries,
      site: site,
      page_number: page.page_number,
      page_size: page.page_size,
      total_pages: page.total_pages,
      total_entries: page.total_entries
    )
  end

  def new(%{assigns: %{site: site}} = conn, _) do
    changeset =
      %Category{site_id: site.id}
      |> Sites.change_category()

    render(conn, "new.html", changeset: changeset, site: site)
  end

  def create(%{assigns: %{site: site}} = conn, %{"category" => category_params}) do
    case Sites.create_category(site, category_params) do
      {:ok, category} ->
        conn
        |> put_flash(:info, "Category created successfully.")
        |> redirect(to: site_category_path(conn, :show, site, URI.encode(category.name)))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, site: site)
    end
  end

  def show(%{assigns: %{site: site}} = conn, %{"category_name" => name}) do
    category = Sites.from_name!(name, site.id, Category)
    render(conn, "show.html", category: category, site: site)
  end

  def public_show(conn, %{"category_name" => name}) do
    site_id = conn.assigns.site.id

    site = Sites.get_site!(site_id)

    category =
      Sites.from_name!(name, Category)
      |> Repo.preload(posts: :categories, posts: :author)

    render(conn, "public_show.html", category: category, site: site)
  end

  def edit(%{assigns: %{site: site}} = conn, %{"category_name" => name}) do
    category = Sites.from_name!(name, Category)
    changeset = Sites.change_category(category)
    render(conn, "edit.html", site: site, category: category, changeset: changeset)
  end

  def update(%{assigns: %{site: site}} = conn, %{
        "category_name" => name,
        "category" => category_params
      }) do
    category = Sites.from_name!(name, Category)

    case Sites.update_category(category, category_params) do
      {:ok, category} ->
        conn
        |> put_flash(:info, "Category updated successfully.")
        |> redirect(to: site_category_path(conn, :show, site, URI.encode(category.name)))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", category: category, changeset: changeset)
    end
  end

  def delete(%{assigns: %{site: site}} = conn, %{"category_name" => name}) do
    category = Sites.from_name!(name, Category)
    {:ok, _category} = Sites.delete_category(category)

    conn
    |> put_flash(:info, "Category deleted successfully.")
    |> redirect(to: site_category_path(conn, :index, site))
  end
end
