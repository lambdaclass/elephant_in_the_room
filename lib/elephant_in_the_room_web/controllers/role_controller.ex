defmodule ElephantInTheRoomWeb.RoleController do
  use ElephantInTheRoomWeb, :controller
  alias ElephantInTheRoom.Repo
  alias ElephantInTheRoom.Auth
  alias ElephantInTheRoom.Auth.Role

  def index(conn, params) do
    page =
      case params do
        %{"page" => page_number} ->
          Role
          |> Repo.paginate(page: page_number)

        %{} ->
          Role
          |> Repo.paginate(page: 1)
      end

    render(
      conn,
      "index.html",
      roles: page.entries,
      page_number: page.page_number,
      page_size: page.page_size,
      total_pages: page.total_pages,
      total_entries: page.total_entries
    )
  end

  def new(conn, _params) do
    changeset = Auth.change_role(%Role{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"role" => role_params}) do
    case Auth.create_role(role_params) do
      {:ok, role} ->
        conn
        |> put_flash(:info, "Role created successfully.")
        |> redirect(to: role_path(conn, :show, role))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    role = Auth.get_role!(id)
    render(conn, "show.html", role: role)
  end

  def edit(conn, %{"id" => id}) do
    role = Auth.get_role!(id)
    changeset = Auth.change_role(role)
    render(conn, "edit.html", role: role, changeset: changeset)
  end

  def update(conn, %{"id" => id, "role" => role_params}) do
    role = Auth.get_role!(id)

    case Auth.update_role(role, role_params) do
      {:ok, role} ->
        conn
        |> put_flash(:info, "Role updated successfully.")
        |> redirect(to: role_path(conn, :show, role))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", role: role, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    role = Auth.get_role!(id)
    {:ok, _role} = Auth.delete_role(role)

    conn
    |> put_flash(:info, "Role deleted successfully.")
    |> redirect(to: role_path(conn, :index))
  end
end
