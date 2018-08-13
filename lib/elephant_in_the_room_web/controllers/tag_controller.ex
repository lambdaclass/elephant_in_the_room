defmodule ElephantInTheRoomWeb.TagController do
  use ElephantInTheRoomWeb, :controller
  import Ecto.Query
  import ElephantInTheRoomWeb.Utils.Utils, only: [get_page: 1]
  alias ElephantInTheRoom.{Posts, Posts.Tag, Repo, Sites, Sites.Site}

  def index(%{assigns: %{site: site}} = conn, params) do
    page =
      case params do
        %{"page" => page_number} ->
          Tag
          |> where([t], t.site_id == ^site.id)
          |> Repo.paginate(page: page_number)

        %{} ->
          Tag
          |> where([t], t.site_id == ^site.id)
          |> Repo.paginate(page: 1)
      end

    render(
      conn,
      "index.html",
      tags: page.entries,
      page_number: page.page_number,
      page_size: page.page_size,
      total_pages: page.total_pages,
      total_entries: page.total_entries,
      bread_crumb: [:sites, site, :tags]
    )
  end

  def new(%{assigns: %{site: site}} = conn, _) do
    changeset =
      %Tag{site_id: site.id}
      |> Posts.change_tag()

    render(
      conn,
      "new.html",
      changeset: changeset,
      site: site,
      bread_crumb: [:sites, site, :tags, %Tag{}]
    )
  end

  def create(%{assigns: %{site: site}} = conn, %{"tag" => tag_params}) do
    case Posts.create_tag(site, tag_params) do
      {:ok, _tag} ->
        redirect(conn, to: site_tag_path(conn, :index, URI.encode(site.name)))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, site: site)
    end
  end

  def show(conn, %{"site_name" => site_name, "tag_name" => name}) do
    tag_site = Sites.from_name!(URI.decode(site_name), Site)
    tag = Sites.from_name!(name, tag_site.id, Tag)
    render(conn, "show.html", tag: tag, site: tag_site)
  end

  def public_show(conn, %{"tag_name" => name} = params) do
    page = get_page(params)
    site_id = conn.assigns.site.id

    site = Sites.get_site!(site_id)

    tag =
      name
      |> Sites.from_name!(site_id, Tag)
      |> Repo.preload(posts: :author)

    posts = Sites.get_tag_with_posts(site, tag.id, amount: 10, page: page)
    tag = %{tag | posts: posts}

    render(conn, "public_show.html", tag: tag, site: site, page: page)
  end

  def edit(%{assigns: %{site: site}} = conn, %{"site_name" => site_name, "tag_name" => name}) do
    tag_site = Sites.from_name!(URI.decode(site_name), Site)
    tag = Sites.from_name!(name, tag_site.id, Tag)
    changeset = Posts.change_tag(tag)

    render(
      conn,
      "edit.html",
      site: site,
      tag: tag,
      changeset: changeset,
      bread_crumb: [:sites, site, :tags, tag]
    )
  end

  def update(%{assigns: %{site: site}} = conn, %{"tag_name" => name, "tag" => tag_params}) do
    tag = Sites.from_name!(name, Tag)

    case Posts.update_tag(tag, tag_params) do
      {:ok, tag} ->
        path = "#{conn.scheme}://#{site.host}:#{conn.port}#{relative_path(conn, tag)}"

        conn
        |> put_flash(:info, "Tag updated successfully.")
        |> redirect(external: path)

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", tag: tag, changeset: changeset)
    end
  end

  def delete(%{assigns: %{site: site}} = conn, %{"tag_name" => name}) do
    tag = Sites.from_name!(name, site.id, Tag)
    {:ok, _tag} = Posts.delete_tag(tag)

    conn
    |> put_flash(:info, "Tag deleted successfully.")
    |> redirect(to: site_tag_path(conn, :index, URI.encode(site.name)))
  end

  defp relative_path(conn, %Tag{name: name}) do
    tag_path(conn, :public_show, URI.encode(name))
  end
end
