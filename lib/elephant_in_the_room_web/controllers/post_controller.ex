defmodule ElephantInTheRoomWeb.PostController do
  use ElephantInTheRoomWeb, :controller

  alias ElephantInTheRoom.Sites
  alias ElephantInTheRoom.Sites.Post

  def index(%{assigns: %{site: site}} = conn, _) do
    posts = Sites.list_posts(site)
    render(conn, "index.html", site: site, posts: posts)
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
    post = Sites.get_post!(site, id)
    render(conn, "show.html", site: site, post: post)
  end

  def edit(%{assigns: %{site: site}} = conn, %{"id" => id}) do
    post = Sites.get_post!(site, id)
    categories = Sites.list_categories(site)
    changeset = Sites.change_post(post)

    render(
      conn,
      "edit.html",
      site: site,
      post: post,
      changeset: changeset,
      categories: categories
    )
  end

  def update(%{assigns: %{site: site}} = conn, %{"id" => id, "post" => post_params}) do
    post = Sites.get_post!(site, id)
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
    post = Sites.get_post!(site, id)
    {:ok, _post} = Sites.delete_post(post)

    conn
    |> put_flash(:info, "Post deleted successfully.")
    |> redirect(to: site_post_path(conn, :index, site))
  end
end
