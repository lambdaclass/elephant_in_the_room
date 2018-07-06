defmodule ElephantInTheRoomWeb.PostController do
  use ElephantInTheRoomWeb, :controller

  alias ElephantInTheRoom.{Sites, Repo}
  alias ElephantInTheRoom.Sites.Post
  alias ElephantInTheRoomWeb.DomainBased
  import Ecto.Query

  def index(%{assigns: %{site: site}} = conn, params) do
    page =
      case params do
        %{"page" => page_number} ->
          Post
          |> where([p], p.site_id == ^site.id)
          |> Repo.paginate(page: page_number)

        %{} ->
          Post
          |> where([p], p.site_id == ^site.id)
          |> Repo.paginate(page: 1)
      end

    render(
      conn,
      "index.html",
      posts: page.entries,
      page_number: page.page_number,
      page_size: page.page_size,
      total_pages: page.total_pages,
      total_entries: page.total_entries,
      bread_crumb: [:sites, site, :posts]
    )
  end

  def new(%{assigns: %{site: site}} = conn, _) do
    categories = Sites.list_categories(site)

    changeset =
      %Post{site_id: site.id}
      |> Sites.change_post()

    render(
      conn,
      "new.html",
      changeset: changeset,
      site: site,
      categories: categories
    )
  end

  def create(%{assigns: %{site: site}} = conn, %{"post" => post_params}) do
    case Sites.create_post(site, post_params) do
      {:ok, post} ->
        conn
        |> put_flash(:info, "Post created successfully.")
        |> redirect(to: site_post_path(conn, :show, site, post))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, site: site)
    end
  end

  def show(%{assigns: %{site: site}} = conn, %{"id" => id}) do
    post = Sites.get_post!(id)
    render(conn, "show.html", site: site, post: post, bread_crumb: [:sites, site, :posts, post])
  end

  def public_show(conn, %{"slug" => slug} = params) do
    with {:ok, site_id} <- DomainBased.get_site_id(conn, params),
         {:ok, site} <- Sites.get_site(site_id),
         {:ok, post} <- Sites.get_post_by_slug(site_id, slug)
    do
      render(conn, "public_show.html", site: site, post: post)
    else
      _ -> render(conn, "404.html")
    end
  end

  def edit(%{assigns: %{site: site}} = conn, %{"id" => id}) do
    post = Sites.get_post!(id)
    categories = Sites.list_categories(site)
    changeset = Sites.change_post(post)

    render(
      conn,
      "edit.html",
      site: site,
      post: post,
      changeset: changeset,
      categories: categories,
      bread_crumb: [:sites, site, :posts, post, :post_edit]
    )
  end

  def update(%{assigns: %{site: site}} = conn, %{"id" => id, "post" => post_params}) do
    post = Sites.get_post!(id)
    post_params_with_site_id = Map.put(post_params, "site_id", site.id)

    case Sites.update_post(post, post_params_with_site_id) do
      {:ok, post} ->
        conn
        |> put_flash(:info, "Post updated successfully.")
        |> redirect(to: site_post_path(conn, :show, site, post))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", post: post, changeset: changeset)
    end
  end

  def delete(%{assigns: %{site: site}} = conn, %{"id" => id}) do
    post = Sites.get_post!(id)
    {:ok, _post} = Sites.delete_post(post)

    conn
    |> put_flash(:info, "Post deleted successfully.")
    |> redirect(to: site_post_path(conn, :index, site))
  end
end
