defmodule ElephantInTheRoomWeb.SiteController do
  use ElephantInTheRoomWeb, :controller
  alias Scrivener.Config
  alias ElephantInTheRoom.Sites.Site
  alias ElephantInTheRoom.{Sites, Repo}

  def index(conn, params) do
    page =
      case params do
        %{"page" => page_number} ->
          Site
          |> Repo.paginate(page: page_number)

        %{} ->
          Site
          |> Repo.paginate(page: 1)
      end

    render(
      conn,
      "index.html",
      sites: page.entries,
      page_number: page.page_number,
      page_size: page.page_size,
      total_pages: page.total_pages,
      total_entries: page.total_entries
    )
  end

  def new(conn, _params) do
    changeset = Sites.change_site(%Site{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"site" => site_params}) do
    case Sites.create_site(site_params) do
      {:ok, site} ->
        conn
        |> put_flash(:info, "Site created successfully.")
        |> redirect(to: site_path(conn, :show, site))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    site = Sites.get_site!(id)
    render(conn, "show.html", site: site)
  end

  def public_show(conn, %{"site_id" => id}) do
    site = Sites.get_site!(id)
    render(conn, "public_show.html", site: site)
  end

  def show_default_site(conn, _params) do
    sites = Sites.list_sites()

    case length(sites) == 0 do
      true ->
        render(conn, "no_site_created")

      false ->
        site =
          sites
          |> hd()
          |> Repo.preload([:categories, [posts: [:categories, :author, :tags]]])

        render(conn, "public_show.html", site: site)
    end
  end

  def edit(conn, %{"id" => id}) do
    site = Sites.get_site!(id)
    changeset = Sites.change_site(site)
    render(conn, "edit.html", site: site, changeset: changeset)
  end

  def update(conn, %{"id" => id, "site" => site_params}) do
    site = Sites.get_site!(id)

    case Sites.update_site(site, site_params) do
      {:ok, site} ->
        conn
        |> put_flash(:info, "Site updated successfully.")
        |> redirect(to: site_path(conn, :show, site))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", site: site, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    site = Sites.get_site!(id)
    {:ok, _site} = Sites.delete_site(site)

    conn
    |> put_flash(:info, "Site deleted successfully.")
    |> redirect(to: site_path(conn, :index))
  end

  def paginate_elements(conn, params) do
    category_page =
      case params do
        %{
          "cat_page" => cat_page_number
        } ->
          Site
          |> Repo.paginate(page: cat_page_number)

        %{} ->
          Site
          |> Repo.paginate(page: 1)
      end

    tag_page =
      case params do
        %{
          "tag_page" => tag_page_number
        } ->
          Site
          |> Repo.paginate(page: tag_page_number)

        %{} ->
          Site
          |> Repo.paginate(page: 1)
      end

    post_page =
      case params do
        %{
          "posts_page" => post_page_number
        } ->
          Site
          |> Repo.paginate(page: post_page_number)

        %{} ->
          Site
          |> Repo.paginate(page: 1)
      end

    render(
      conn,
      "index.html",
      tag_page: %{
        tags: tag_page.entries,
        page_number: tag_page.page_number,
        page_size: tag_page.page_size,
        total_pages: tag_page.total_pages,
        total_entries: tag_page.total_entries
      },
      post_page: %{
        posts: post_page.entries,
        page_number: post_page.page_number,
        page_size: post_page.page_size,
        total_pages: post_page.total_pages,
        total_entries: post_page.total_entries
      },
      cat_page: %{
        categories: category_page.entries,
        page_number: category_page.page_number,
        page_size: category_page.page_size,
        total_pages: category_page.total_pages,
        total_entries: category_page.total_entries
      }
    )
  end
end
