defmodule ElephantInTheRoomWeb.TagController do
  use ElephantInTheRoomWeb, :controller

  alias ElephantInTheRoom.Sites
  alias ElephantInTheRoom.Sites.Tag

  def index(%{assigns: %{site: site}} = conn, _) do
    tags = Sites.list_tags(site)
    render(conn, "index.html", tags: tags, site: site)
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
        conn
        |> put_flash(:info, "Tag created successfully.")
        |> redirect(to: site_tag_path(conn, :show, site, tag))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, site: site)
    end
  end

  def show(%{assigns: %{site: site}} = conn, %{"id" => id}) do
    tag = Sites.get_tag!(id)
    render(conn, "show.html", tag: tag, site: site)
  end

  def edit(%{assigns: %{site: site}} = conn, %{"id" => id}) do
    tag = Sites.get_tag!(site, id)
    changeset = Sites.change_tag(tag)
    render(conn, "edit.html", tag: tag, site: site, changeset: changeset)
  end

  def update(%{assigns: %{site: site}} = conn, %{"id" => id, "tag" => tag_params}) do
    tag = Sites.get_tag!(id)

    case Sites.update_tag(tag, tag_params) do
      {:ok, tag} ->
        conn
        |> put_flash(:info, "Tag updated successfully.")
        |> redirect(to: site_tag_path(conn, :show, site, tag))

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
