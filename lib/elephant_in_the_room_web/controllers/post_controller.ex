defmodule ElephantInTheRoomWeb.PostController do
  use ElephantInTheRoomWeb, :controller

  alias ElephantInTheRoom.Sites
  alias ElephantInTheRoom.Sites.Post

  def action(conn, _params) do
    site = Sites.get_site!(conn.params["site_id"])
    args = [conn, conn.params, site]
    apply(__MODULE__, action_name(conn), args)
  end

  def index(conn, _params, site) do
    posts = Sites.list_posts()
    render(conn, "index.html", site: site, posts: posts)
  end

  def new(conn, _params, site) do
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

  def create(conn, %{"post" => post_params}, site) do
    case Sites.create_post(site, post_params) do
      {:ok, post} ->
        conn
        |> put_flash(:info, "Post created successfully.")
        |> redirect(to: site_post_path(conn, :show, site, post))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, site: site)
    end
  end

  def show(conn, %{"id" => id}, site) do
    post = Sites.get_post!(id)
    render(conn, "show.html", site: site, post: post)
  end

  def edit(conn, %{"id" => id}, site) do
    post = Sites.get_post!(site, id)
    changeset = Sites.change_post(post)
    render(conn, "edit.html", site: site, post: post, changeset: changeset)
  end

  def update(conn, %{"id" => id, "post" => post_params}, site) do
    post = Sites.get_post!(id)

    case Sites.update_post(post, post_params) do
      {:ok, post} ->
        conn
        |> put_flash(:info, "Post updated successfully.")
        |> redirect(to: site_post_path(conn, :show, site, post))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", post: post, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}, site) do
    post = Sites.get_post!(id)
    {:ok, _post} = Sites.delete_post(post)

    conn
    |> put_flash(:info, "Post deleted successfully.")
    |> redirect(to: site_post_path(conn, :index, site))
  end
end
