defmodule ElephantInTheRoomWeb.AuthorController do
  use ElephantInTheRoomWeb, :controller
  alias ElephantInTheRoom.{Repo, Sites, Sites.Author}

  def index(conn, params) do
    page =
      case params do
        %{"page" => page} ->
          Author |> Repo.paginate(page: page)

        %{} ->
          Author |> Repo.paginate(page: 1)
      end

    render(
      conn,
      "index.html",
      authors: page.entries,
      page_number: page.page_number,
      page_size: page.page_size,
      total_pages: page.total_pages,
      total_entries: page.total_entries
    )
  end

  def new(conn, _params) do
    changeset = Sites.change_author(%Author{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"author" => author_params}) do
    case Sites.create_author(author_params) do
      {:ok, author} ->
        conn
        |> put_flash(:info, "Author created successfully.")
        |> redirect(to: author_path(conn, :show, URI.encode(author.name)))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"author_name" => name}) do
    author = author_from_name(name)
    render(conn, "show.html", author: author)
  end

  def public_show(conn, %{"author_name" => name}) do
    author =
      author_from_name(name)
      |> Repo.preload(posts: [:site])

    render(conn, "public_show.html", author: author)
  end

  def edit(conn, %{"author_name" => name}) do
    author = author_from_name(name)
    changeset = Sites.change_author(author)
    render(conn, "edit.html", author: author, changeset: changeset)
  end

  def update(conn, %{"author_name" => name, "author" => author_params}) do
    author = author_from_name(name)

    case Sites.update_author(author, author_params) do
      {:ok, author} ->
        conn
        |> put_flash(:info, "Author updated successfully.")
        |> redirect(to: author_path(conn, :show, URI.encode(author.name)))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", author: author, changeset: changeset)
    end
  end

  def delete(conn, %{"author_name" => name}) do
    author = author_from_name(name)
    {:ok, _author} = Sites.delete_author(author)

    conn
    |> put_flash(:info, "Author deleted successfully.")
    |> redirect(to: author_path(conn, :index))
  end

  defp author_from_name(name) do
    name
    |> URI.decode()
    |> Sites.get_author_by_name!()
  end
end
