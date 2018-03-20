defmodule ElephantInTheRoomWeb.SiteController do
  use ElephantInTheRoomWeb, :controller

  alias ElephantInTheRoom.Sites
  alias ElephantInTheRoom.Sites.Site
  alias ElephantInTheRoom.Repo

  def index(conn, params) do
    case params do
      %{"page" => page} ->
        page =
          Site
          |> Repo.paginate(page: page)

      %{} ->
        page =
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
        render(conn, "public_show.html", site: hd(sites))
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
