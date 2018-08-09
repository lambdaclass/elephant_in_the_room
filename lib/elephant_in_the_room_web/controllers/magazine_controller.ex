defmodule ElephantInTheRoomWeb.MagazineController do
  use ElephantInTheRoomWeb, :controller

  alias ElephantInTheRoom.Sites
  alias ElephantInTheRoom.Sites.Magazine

  def index(%{assigns: %{site: site}} = conn, params) do
    magazines = Sites.list_magazines(site, params["page"])
    render(conn, "index.html", magazines: magazines)
  end

  def new(conn, _params) do
    changeset = Sites.change_magazine(%Magazine{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(%{assigns: %{site: site}} = conn, %{"magazine" => magazine_params}) do
    site_magazine_params = Map.put(magazine_params, "site_id", site.id)

    case Sites.create_magazine(site_magazine_params) do
      {:ok, magazine} ->
        conn
        |> put_flash(:info, "Magazine created successfully.")
        |> redirect(to: URI.encode(magazine_path(conn, :public_show, magazine.title)))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def public_show(%{assigns: %{site: site}} = conn, %{"title" => title}) do
    magazine = get_magazine(site.id, title)
    magazines = Sites.list_magazines(site, 0)

    render(conn, "public_show.html", magazine: magazine, magazines: magazines)
  end

  def public_index(%{assigns: %{site: site}} = conn, params) do
    magazines = Sites.list_magazines(site, params["page"])
    render(conn, "public_index.html", magazines: magazines)
  end

  def current(%{assigns: %{site: site}} = conn, _params) do
    magazine = Sites.get_current_magazine(site.id, [posts: :author])
    magazines = Sites.list_magazines(site, 0)

    render(conn, "public_show.html", magazine: magazine, magazines: magazines)
  end

  def edit(%{assigns: %{site: site}} = conn, %{"title" => title}) do
    magazine = get_magazine(site.id, title)
    changeset = Sites.change_magazine(magazine)
    render(conn, "edit.html", magazine: magazine, changeset: changeset)
  end

  def update(%{assigns: %{site: site}} = conn, %{"title" => title, "magazine" => magazine_params}) do
    magazine = get_magazine(site.id, title)

    case Sites.update_magazine(magazine, magazine_params) do
      {:ok, magazine} ->
        conn
        |> put_flash(:info, "Magazine updated successfully.")
        |> redirect(to: URI.encode(magazine_path(conn, :public_show, magazine.title)))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", magazine: magazine, changeset: changeset)
    end
  end

  def delete(%{assigns: %{site: site}} = conn, %{"title" => title}) do
    magazine = get_magazine(site.id, title)
    {:ok, _magazine} = Sites.delete_magazine(magazine)

    conn
    |> put_flash(:info, "Magazine deleted successfully.")
    |> redirect(to: site_magazine_path(conn, :index, site.id))
  end

  defp get_magazine(site_id, enc_title) do
    URI.decode(enc_title)
    |> Sites.get_magazine!(site_id, [posts: :author])
  end
end
