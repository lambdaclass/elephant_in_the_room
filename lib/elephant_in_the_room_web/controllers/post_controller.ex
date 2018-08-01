defmodule ElephantInTheRoomWeb.PostController do
  use ElephantInTheRoomWeb, :controller
  alias ElephantInTheRoom.{Sites, Sites.Post}
  alias Phoenix.Controller

  def index(conn, %{"magazine_title" => magazine_title} = params) do
    magazine = get_magazine!(magazine_title)
    page = Sites.get_posts_paginated(magazine, params["page"])

    index(conn, params, page, magazine_title, nil)
  end

  def index(%{assigns: %{site: site}} = conn, params) do
    page = Sites.get_posts_paginated(site, params["page"])

    index(conn, params, page, nil, [:sites, site, :posts])
  end

  def index(conn, _params, page, magazine_title, bread_crumb) do
    render(
      conn,
      "index.html",
      magazine_title: magazine_title,
      posts: page.entries,
      page_number: page.page_number,
      page_size: page.page_size,
      total_pages: page.total_pages,
      total_entries: page.total_entries,
      bread_crumb: bread_crumb
    )
  end

  def new(%{assigns: %{site: site}} = conn, params) do
    magazine = if params["magazine_title"], do: get_magazine!(params["magazine_title"]), else: nil
    categories = Sites.list_categories(site)
    changeset = Sites.change_post(%Post{})

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
    magazine = get_magazine!(magazine_title)
    case Sites.create_post(magazine, post_params) do
      {:ok, post} ->
        path = "#{conn.scheme}://#{site.host}:#{conn.port}#{relative_path(conn, magazine, post)}"

        redirect(conn, external: path)

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, magazine: magazine)
    end
  end

  def create(%{assigns: %{site: site}} = conn, %{"post" => post_params}) do
    case Sites.create_post(site, post_params) do
      {:ok, post} ->
        path = "#{conn.scheme}://#{site.host}:#{conn.port}#{relative_path(conn, post)}"

        redirect(conn, external: path)

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, magazine: nil)
    end
  end

  def show(%{assigns: %{site: site}} = conn, %{"slug" => slug}) do
    post = Sites.get_post_by_slug!(site.id, slug)
    render(conn, "show.html", site: site, post: post, bread_crumb: [:sites, site, :posts, post])
  end

  def public_show(conn, %{"magazine_title" => magazine_title, "slug" => slug}) do
    magazine = get_magazine!(magazine_title)
    post = Sites.get_magazine_post_by_slug!(magazine, slug)
    meta = Post.generate_og_meta(conn, post)
    render(conn, "public_show.html", post: post, meta: meta)
  end

  def public_show(%{assigns: %{site: site}} = conn, %{"slug" => slug}) do
    post = Sites.get_post_by_slug!(site.id, slug)
    meta = Post.generate_og_meta(conn, post)
    Post.increase_views_for_popular_by_1(post)
    render(conn, "public_show.html", site: site, post: post, meta: meta)
  end

  def edit(%{assigns: %{site: site}} = conn, %{"slug" => slug}) do
    post = Sites.get_post_by_slug!(site.id, slug)
    categories = Sites.list_categories(site)
    changeset = Sites.change_post(post)

    render(
      conn,
      "edit.html",
      site: site,
      post: post,
      changeset: changeset,
      categories: categories,
      info: Controller.get_flash(conn, :info),
      bread_crumb: [:sites, site, :posts, post, :post_edit]
    )
  end

  def update(%{assigns: %{site: site}} = conn, %{
        "cover_delete" => "true",
        "slug" => slug
      }) do
    post = Sites.get_post_by_slug!(site.id, slug)

    {:ok, post_no_cover} = Sites.delete_cover(post)

    render(conn, "edit.html", post: post_no_cover, changeset: Sites.change_post(post_no_cover))
  end

  def update(%{assigns: %{site: site}} = conn, %{"slug" => slug, "post" => post_params}) do
    post = Sites.get_post_by_slug!(site.id, slug)
    post_params_with_site_id = Map.put(post_params, "site_id", site.id)

    case Sites.update_post(post, post_params_with_site_id) do
      {:ok, post} ->
        path =
          "#{conn.scheme}://#{site.host}:#{conn.port}#{relative_path(conn, post)}"
          |> URI.encode()

        conn
        |> redirect(external: path)

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", post: post, changeset: changeset)
    end
  end

  def delete(%{assigns: %{site: site}} = conn, %{"slug" => slug}) do
    post = Sites.get_post_by_slug!(site.id, slug)
    {:ok, _post} = Sites.delete_post(post)

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

  defp get_magazine!(enc_title) do
    URI.decode(enc_title)
    |> Sites.get_magazine!([posts: :author])
  end
end
