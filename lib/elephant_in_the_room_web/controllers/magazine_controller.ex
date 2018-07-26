defmodule ElephantInTheRoomWeb.MagazineController do
  use ElephantInTheRoomWeb, :controller

  alias ElephantInTheRoom.Sites
  alias ElephantInTheRoom.Sites.Magazine

  def index(%{assigns: %{site: site}} = conn, _params) do
    magazines = Sites.list_magazines(site)
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
        |> redirect(to: magazine_path(conn, :show, magazine))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  # def show(conn, %{"id" => id}) do
  #   magazine = Sites.get_magazine!(id)
  #   render(conn, "show.html", magazine: magazine)
  # end

  def edit(conn, %{"id" => id}) do
    magazine = Sites.get_magazine!(id)
    changeset = Sites.change_magazine(magazine)
    render(conn, "edit.html", magazine: magazine, changeset: changeset)
  end

  def update(conn, %{"id" => id, "magazine" => magazine_params}) do
    magazine = Sites.get_magazine!(id)

    case Sites.update_magazine(magazine, magazine_params) do
      {:ok, magazine} ->
        conn
        |> put_flash(:info, "Magazine updated successfully.")
        |> redirect(to: magazine_path(conn, :show, magazine))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", magazine: magazine, changeset: changeset)
    end
  end

  def delete(%{assigns: %{site: site}} = conn, %{"id" => id}) do
    magazine = Sites.get_magazine!(id)
    {:ok, _magazine} = Sites.delete_magazine(magazine)

    conn
    |> put_flash(:info, "Magazine deleted successfully.")
    |> redirect(to: site_magazine_path(conn, :index, site.name))
  end
end
