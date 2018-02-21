defmodule ElephantInTheRoomWeb.PostController do
  use ElephantInTheRoomWeb, :controller

  alias ElephantInTheRoom.{Sites, Repo}
  alias ElephantInTheRoom.Sites.{Post, Category}
  plug(:assign_category)

  def action(conn, _) do
    site = Sites.get_site!(conn.params["site_id"])
    category = Sites.get_category!(conn.params["category_id"])
    args = [conn, conn.params, site, category]
    apply(__MODULE__, action_name(conn), args)
  end

  def index(conn, _params, site, category) do
    posts = Sites.list_posts(category)
    render(conn, "index.html", posts: posts, site: site, category: category)
  end

  def new(conn, _params, site, category) do
    changeset =
      %Post{category_id: category.id}
      |> Sites.change_post()

    render(conn, "new.html", changeset: changeset, site: site, category: category)
  end

  def create(conn, %{"post" => post_params}, site, category) do
    case Sites.create_post(category, post_params) do
      {:ok, post} ->
        conn
        |> put_flash(:info, "Post created successfully.")
        |> redirect(to: site_category_post_path(conn, :show, site, category, post))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, site: site, category: category)
    end
  end

  def show(conn, %{"id" => id}, site, category) do
    post = Sites.get_post!(category, id)

    render(conn, "show.html", site: site, category: category, post: post)
  end

  def edit(conn, %{"id" => id}, site, category) do
    post = Sites.get_post!(category, id)
    changeset = Sites.change_post(post)
    render(conn, "edit.html", post: post, changeset: changeset, site: site, category: category)
  end

  def update(conn, %{"id" => id, "post" => post_params}, category) do
    post = Sites.get_post!(id)

    case Sites.update_post(post, post_params) do
      {:ok, post} ->
        conn
        |> put_flash(:info, "Post updated successfully.")
        |> redirect(to: site_category_post_path(conn, :show, category, post))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", category: category, post: post, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}, site, category) do
    post = Sites.get_post!(category, id)
    {:ok, _post} = Sites.delete_post(post)

    conn
    |> put_flash(:info, "Post deleted successfully.")
    |> redirect(to: site_category_post_path(conn, :index, site, category))
  end

  defp assign_category(conn, _opts) do
    case conn.params do
      %{"category_id" => category_id} ->
        category = Repo.get(Category, category_id)
        assign(conn, :category, category)

      _ ->
        conn
    end
  end
end
