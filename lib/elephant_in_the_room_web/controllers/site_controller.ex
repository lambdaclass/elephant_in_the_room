defmodule ElephantInTheRoomWeb.SiteController do
  use ElephantInTheRoomWeb, :controller
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
      total_entries: page.total_entries,
      bread_crumb: [:sites]
    )
  end

  def public_index(conn, params) do
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
      "public_index.html",
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

  def paginate_elements(site, params) do
    category_page =
      case params do
        %{
          "cat_page" => cat_page_number
        } ->
          Repo.paginate(site.categories, page: cat_page_number)

        %{} ->
          Repo.paginate(site.categories, page: 1)
      end

    tag_page =
      case params do
        %{
          "tag_page" => tag_page_number
        } ->
          Repo.paginate(site.tags, page: tag_page_number)

        %{} ->
          Repo.paginate(site.tags, page: 1)
      end

    post_page =
      case params do
        %{
          "post_page" => post_page_number
        } ->
          Repo.paginate(site.posts, page: post_page_number)

        %{} ->
          Repo.paginate(site.posts, page: 1)
      end

    %{
      tag_page: tag_page,
      post_page: post_page,
      cat_page: category_page
    }
  end

  def show(conn, %{"id" => id} = params) do
    site = Sites.get_site!(id)
    pages = paginate_elements(site, params)

    render(
      conn,
      "show.html",
      site: site,
      pages: pages,
      bread_crumb: [:sites, site]
    )
  end

  def public_show(conn, params) do
    if conn.host != "localhost" do
      site =
        Repo.get_by!(Site, host: conn.host)
        |> Repo.preload([:posts, :categories])

      render(conn, "public_show.html", site: site)
    else
      site =
        Sites.get_site!(params["id"])
        |> Repo.preload([:posts, :categories])

      render(conn, "public_show.html", site: site)
    end
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
end
