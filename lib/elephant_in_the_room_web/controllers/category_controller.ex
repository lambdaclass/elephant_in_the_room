defmodule ElephantInTheRoomWeb.CategoryController do
  use ElephantInTheRoomWeb, :controller
  alias ElephantInTheRoom.Sites
  alias ElephantInTheRoom.Sites.Category
  alias ElephantInTheRoom.Repo

  def index(%{assigns: %{site: site}} = conn, params) do
    page =
      case params do
        %{"page" => page_number} ->
          Category
          |> Repo.paginate(page: page_number)

        %{} ->
          Category
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
        |> redirect(to: site_category_path(conn, :show, site, category))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, site: site)
    end
  end

  def show(%{assigns: %{site: site}} = conn, %{"id" => id}) do
    category = Sites.get_category!(id)
    render(conn, "show.html", category: category, site: site)
  end

  def public_show(%{assigns: %{site: site}} = conn, %{"category_id" => category_id} = params) do
    # site =
    #   if conn.host != "localhost",
    #     do: conn.site,
    #     else: Sites.get_site!(params["id"])

    category =
      Sites.get_category!(category_id)
      |> Repo.preload(posts: :categories, posts: :author)

    render(conn, "public_show.html", category: category, site: site)
  end

  def edit(%{assigns: %{site: site}} = conn, %{"id" => id}) do
    category = Sites.get_category!(id)
    changeset = Sites.change_category(category)
    render(conn, "edit.html", site: site, category: category, changeset: changeset)
  end

  def update(%{assigns: %{site: site}} = conn, %{"id" => id, "category" => category_params}) do
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

  def delete(%{assigns: %{site: site}} = conn, %{"id" => id}) do
    category = Sites.get_category!(id)
    {:ok, _category} = Sites.delete_category(category)

    conn
    |> put_flash(:info, "Category deleted successfully.")
    |> redirect(to: site_category_path(conn, :index, site))
  end
end
