defmodule ElephantInTheRoomWeb.UserController do
  use ElephantInTheRoomWeb, :controller
  alias ElephantInTheRoom.{Repo, Auth, Auth.User}

  def index(conn, params) do
    page =
      case params do
        %{"page" => page_number} ->
          User
          |> Repo.paginate(page: page_number)

        %{} ->
          User
          |> Repo.paginate(page: 1)
      end

    entries = page.entries |> Repo.preload(:role)

    render(
      conn,
      "index.html",
      users: entries,
      page_number: page.page_number,
      page_size: page.page_size,
      total_pages: page.total_pages,
      total_entries: page.total_entries
    )
  end

  def new(conn, _params) do
    changeset = Auth.change_user(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    case Auth.create_user(user_params) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "User created successfully.")
        |> redirect(to: user_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"user_name" => name}) do
    user = Auth.from_username!(name)
    render(conn, "show.html", user: user)
  end

  def edit(conn, %{"user_name" => name}) do
    user = Auth.from_username!(name)
    changeset = Auth.change_user(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(conn, %{"user_name" => name, "user" => user_params}) do
    user = Auth.from_username!(name)

    case Auth.update_user(user, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: user_path(conn, :show, URI.encode(user.username)))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def delete(conn, %{"user_name" => name}) do
    user = Auth.from_username!(name)
    Auth.delete_user(user)
    redirect(conn,to: user_path(conn, :index))
  end
end
