defmodule ElephantInTheRoomWeb.PostController do
  use ElephantInTheRoomWeb, :controller
  alias ElephantInTheRoom.{Posts, Posts.Post, Sites}
  alias Phoenix.Controller

  def index(%{assigns: %{site: site}} = conn, %{"magazine_title" => magazine_title} = params) do
    magazine = get_magazine!(site.id, magazine_title)
    page = Posts.get_posts_paginated(magazine, params["page"])

    index(conn, params, page, magazine, [:sites, site, :magazines, magazine, :posts])
  end

  def index(%{assigns: %{site: site}} = conn, params) do
    page = Posts.get_posts_paginated(site, params["page"])

    index(conn, params, page, nil, [:sites, site, :posts])
  end

  def index(conn, _params, page, magazine, bread_crumb) do
    render(
      conn,
      "index.html",
      magazine: magazine,
      posts: page.entries,
      page_number: page.page_number,
      page_size: page.page_size,
      total_pages: page.total_pages,
      total_entries: page.total_entries,
      bread_crumb: bread_crumb
    )
  end

  def new(%{assigns: %{site: site}} = conn, params) do
    magazine = if params["magazine_title"], do: get_magazine!(site.id, params["magazine_title"]), else: nil
    categories = Posts.list_categories(site)
    changeset = Post.changeset(%Post{}, %{})

    render(
      conn,
      "new.html",
      magazine: magazine,
      changeset: changeset,
      site: site,
      info: Controller.get_flash(conn, :info),
      categories: categories
    )
  end

  def create(%{assigns: %{site: site}} = conn, %{"magazine_title" => magazine_title, "post" => post_params}) do
    magazine = get_magazine!(site.id, magazine_title)
    case Posts.create_post(magazine, post_params) do
      {:ok, post} ->
        path = "#{conn.scheme}://#{site.host}:#{conn.port}#{relative_path(conn, magazine, post)}"

        redirect(conn, external: path)

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, magazine: magazine)
    end
  end

  def create(%{assigns: %{site: site}} = conn, %{"post" => post_params}) do
    case Posts.create_post(site, post_params) do
      {:ok, post} ->
        path = "#{conn.scheme}://#{site.host}:#{conn.port}#{relative_path(conn, post)}"

        redirect(conn, external: path)

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, magazine: nil)
    end
  end

  def show(%{assigns: %{site: site}} = conn, %{"slug" => slug}) do
    post = Posts.get_post_by_slug!(site.id, slug)
    render(conn, "show.html", site: site, post: post, bread_crumb: [:sites, site, :posts, post])
  end

  def public_show(%{assigns: %{site: site}} = conn, %{"magazine_title" => magazine_title, "slug" => slug}) do
    magazine = get_magazine!(site.id, magazine_title)
    post = Posts.get_magazine_post_by_slug!(magazine, slug)
    meta = Posts.gen_og_meta_for_post(conn, post)
    render(conn, "public_show.html", post: post, magazine: magazine, meta: meta)
  end

  def public_show(%{assigns: %{site: site}} = conn, %{"slug" => slug}) do
    post = Posts.get_post_by_slug!(site.id, slug)
    meta = Posts.gen_og_meta_for_post(conn, post)
    Post.increase_views_for_popular_by_1(post)
    render(conn, "public_show.html", magazine: nil, post: post, meta: meta)
  end

  def edit(%{assigns: %{site: site}} = conn, %{"magazine_title" => magazine_title, "slug" => slug}) do
    magazine = get_magazine!(site.id, magazine_title)
    post = Posts.get_magazine_post_by_slug!(magazine, slug)
    edit(conn, magazine, post, [:sites, site, :magazines, magazine, :posts, post])
  end

  def edit(%{assigns: %{site: site}} = conn, %{"slug" => slug}) do
    post = Posts.get_post_by_slug!(site.id, slug)
    edit(conn, nil, post, [:sites, site, :posts, post, :post_edit])
  end

  def edit(%{assigns: %{site: site}} = conn, magazine, post, bread_crumb) do
    categories = Posts.list_categories(site)
    changeset = Posts.change_post(post)

    render(
      conn,
      "edit.html",
      site: site,
      magazine: magazine,
      post: post,
      changeset: changeset,
      categories: categories,
      info: Controller.get_flash(conn, :info),
      bread_crumb: bread_crumb
    )
  end

  def update(%{assigns: %{site: site}} = conn, %{
        "magazine_title" => magazine_title,
        "cover_delete" => "true",
        "slug" => slug
      }) do
    magazine = get_magazine!(site.id, magazine_title)
    post = Posts.get_magazine_post_by_slug!(magazine, slug)

    {:ok, post_no_cover} = Posts.delete_cover(post)

    render(conn, "edit.html", post: post_no_cover, changeset: Posts.change_post(post_no_cover), magazine: magazine)
  end

  def update(%{assigns: %{site: site}} = conn, %{
        "cover_delete" => "true",
        "slug" => slug
      }) do
    post = Posts.get_post_by_slug!(site.id, slug)

    {:ok, updated_post} = Posts.delete_cover(post)

    render(conn, "edit.html", post: updated_post, changeset: Posts.change_post(updated_post), magazine: nil)
  end

  def update(%{assigns: %{site: site}} = conn, %{
    "thumbnail_delete" => "true",
    "slug" => slug
  }) do
    post = Posts.get_post_by_slug!(site.id, slug)

    {:ok, updated_post} = Posts.delete_thumbnail(post)

    render(conn, "edit.html", post: updated_post, changeset: Posts.change_post(updated_post), magazine: nil)
  end

  def update(%{assigns: %{site: site}} = conn, %{"magazine_title" => magazine_title, "slug" => slug, "post" => post_params}) do
    magazine = get_magazine!(site.id, magazine_title)
    post = Posts.get_magazine_post_by_slug!(magazine, slug)

    case Posts.update_post(post, post_params) do
      {:ok, post} ->
        path =
          "#{conn.scheme}://#{site.host}:#{conn.port}#{relative_path(conn, magazine, post)}"
          |> URI.encode()

        conn
        |> redirect(external: path)

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", post: post, changeset: changeset, magazine: magazine)
    end
  end

  def update(%{assigns: %{site: site}} = conn, %{"slug" => slug, "post" => post_params}) do
    post = Posts.get_post_by_slug!(site.id, slug)
    post_params_with_site_id = Map.put(post_params, "site_id", site.id)

    case Posts.update_post(post, post_params_with_site_id) do
      {:ok, post} ->
        path =
          "#{conn.scheme}://#{site.host}:#{conn.port}#{relative_path(conn, post)}"
          |> URI.encode()

        conn
        |> redirect(external: path)

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", post: post, changeset: changeset, magazine: nil)
    end
  end

  def delete(%{assigns: %{site: site}} = conn, %{"magazine_title" => magazine_title, "slug" => slug}) do
    magazine = get_magazine!(site.id, magazine_title)
    post = Posts.get_magazine_post_by_slug!(magazine, slug)
    {:ok, _post} = Posts.delete_post(post)

    conn
    |> put_flash(:info, "Post deleted successfully.")
    |> redirect(to: site_magazine_post_path(conn, :index, site.name, magazine.title))
  end

  def delete(%{assigns: %{site: site}} = conn, %{"slug" => slug}) do
    post = Posts.get_post_by_slug!(site.id, slug)
    {:ok, _post} = Posts.delete_post(post)

    conn
    |> put_flash(:info, "Post deleted successfully.")
    |> redirect(to: site_post_path(conn, :index, site.name))
  end

  defp relative_path(conn, %Post{inserted_at: date, slug: slug}) do
    post_path(conn, :public_show, date.year, date.month, date.day, slug)
  end

  defp relative_path(conn, %{title: magazine_title}, %Post{inserted_at: date, slug: slug}) do
    magazine_post_path(conn, :public_show, magazine_title, date.year, date.month, date.day, slug)
  end

  defp get_magazine!(site_id, enc_title) do
    URI.decode(enc_title)
    |> Sites.get_magazine!(site_id, [posts: :author])
  end
end
