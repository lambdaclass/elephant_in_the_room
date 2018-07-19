defmodule ElephantInTheRoomWeb.TagController do
  use ElephantInTheRoomWeb, :controller

  alias ElephantInTheRoom.Sites
  alias ElephantInTheRoom.Sites.Tag
  alias ElephantInTheRoom.Repo
  import Ecto.Query

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
      |> Sites.change_tag()

    render(conn, "new.html", changeset: changeset, site: site)
  end

  def create(%{assigns: %{site: site}} = conn, %{"tag" => tag_params}) do
    case Sites.create_tag(site, tag_params) do
      {:ok, tag} ->
        redirect(conn, to: tag_path(conn, :public_show, tag.id))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, site: site)
    end
  end

  def show(%{assigns: %{site: site}} = conn, %{"id" => id}) do
    tag = Sites.get_tag!(id)
    render(conn, "show.html", tag: tag, site: site)
  end

  def public_show(conn, %{"tag_id" => tag_id}) do
    site_id = conn.assigns.site.id

    site = Sites.get_site!(site_id)

    tag =
      Sites.get_tag!(tag_id)
      |> Repo.preload(posts: :author)

    render(conn, "public_show.html", tag: tag, site: site)
  end

  def edit(%{assigns: %{site: site}} = conn, %{"id" => id}) do
    tag = Sites.get_tag!(id)
    changeset = Sites.change_tag(tag)
    render(conn, "edit.html",
      site: site,
      tag: tag,
      changeset: changeset,
      bread_crumb: [:sites, site, :tags, tag])
  end

  def update(conn, %{"id" => id, "tag" => tag_params}) do
    tag = Sites.get_tag!(id)

    case Sites.update_tag(tag, tag_params) do
      {:ok, tag} ->
        conn
        |> put_flash(:info, "Tag updated successfully.")
        |> redirect(to: tag_path(conn, :public_show, tag.id))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", tag: tag, changeset: changeset)
    end
  end

  def delete(%{assigns: %{site: site}} = conn, %{"id" => id}) do
    tag = Sites.get_tag!(id)
    {:ok, _tag} = Sites.delete_tag(tag)

    conn
    |> put_flash(:info, "Tag deleted successfully.")
    |> redirect(to: site_tag_path(conn, :index, site))
  end
end
