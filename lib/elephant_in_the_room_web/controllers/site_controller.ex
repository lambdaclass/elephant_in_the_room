defmodule ElephantInTheRoomWeb.SiteController do
  use ElephantInTheRoomWeb, :controller
  import ElephantInTheRoomWeb.Utils.Utils, only: [get_page: 1]
  alias ElephantInTheRoom.{Posts.Featured, Repo, Sites, Sites.Ad, Sites.Site}

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
        |> redirect(to: site_path(conn, :show, URI.encode(site.name)))

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

  def show(conn, %{"name" => name} = params) do
    site = Sites.get_site_by_name!(URI.decode(name))
    pages = paginate_elements(site, params)

    render(
      conn,
      "show.html",
      site: site,
      pages: pages,
      bread_crumb: [:sites, site]
    )
  end

  def public_show(conn, _params) do
    site =
      Repo.get_by!(Site, host: conn.host)
      |> Repo.preload(Sites.default_site_preload())

    ads = Ad.get(site, :all)
    meta = Sites.gen_og_meta_for_site(conn)

    {featured_posts_with_levels, aditional_posts} =
      Featured.get_all_featured_posts_ensure_filled_cached(site.id, 15)

    render(
      conn,
      "public_show.html",
      site: site,
      meta: meta,
      latest_posts: Sites.get_latest_posts(site, amount: 15),
      section_1_posts: Featured.get_posts_from_level_pair(1, featured_posts_with_levels),
      section_2_posts: Featured.get_posts_from_level_pair(2, featured_posts_with_levels),
      section_3_posts: Featured.get_posts_from_level_pair(3, featured_posts_with_levels),
      section_4_posts: Featured.get_posts_from_level_pair(4, featured_posts_with_levels),
      latest_posts: aditional_posts,
      columnists_and_posts: Sites.get_columnists_and_posts(site, 10),
      popular_posts: Sites.get_popular_posts(site, amount: 10),
      ads: ads
    )
  end

  def public_show_popular(conn, params) do
    page = get_page(params)
    popular_posts = Sites.get_popular_posts(conn.assigns.site, page: page)

    render(conn, "public_show_popular.html", posts: popular_posts, page: page)
  end

  def public_show_latest(conn, params) do
    page = get_page(params)
    latest_posts = Sites.get_latest_posts(conn.assigns.site, page: page, amount: 10)

    render(conn, "public_show_latest.html", posts: latest_posts, page: page)
  end

  def show_default_site(conn, _params) do
    sites = Sites.list_sites()

    case Enum.epmty?(sites) do
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

  def edit(conn, %{"name" => name}) do
    site = Sites.get_site_by_name!(URI.decode(name))
    changeset = Sites.change_site(site)
    render(conn, "edit.html", site: site, changeset: changeset)
  end

  def update(conn, %{"image_delete" => "true", "name" => name}) do
    site = Sites.from_name!(name, Site)
    {:ok, site_no_image} = Sites.delete_site_field(site, "image")
    changeset = Sites.change_site(site_no_image)
    render(conn, "edit.html", site: site_no_image, changeset: changeset)
  end

  def update(conn, %{"post_image_delete" => "true", "name" => name}) do
    site = Sites.from_name!(name, Site)
    {:ok, site_no_post_image} = Sites.delete_site_field(site, "post_default_image")
    changeset = Sites.change_site(site_no_post_image)
    render(conn, "edit.html", site: site_no_post_image, changeset: changeset)
  end

  def update(conn, %{"favicon_delete" => "true", "name" => name}) do
    site = Sites.from_name!(name, Site)
    {:ok, site_no_image} = Sites.delete_site_field(site, "favicon")
    changeset = Sites.change_site(site_no_image)
    render(conn, "edit.html", site: site_no_image, changeset: changeset)
  end

  def update(conn, %{"name" => name, "site" => site_params}) do
    site = Sites.get_site_by_name!(URI.decode(name))

    case Sites.update_site(site, site_params) do
      {:ok, site} ->
        conn
        |> put_flash(:info, "Site updated successfully.")
        |> redirect(to: site_path(conn, :show, site.name))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", site: site, changeset: changeset)
    end
  end

  def delete(conn, %{"name" => name}) do
    site = Sites.get_site_by_name!(URI.decode(name))
    {:ok, _site} = Sites.delete_site(site)

    conn
    |> put_flash(:info, "Site deleted successfully.")
    |> redirect(to: site_path(conn, :index))
  end
end
