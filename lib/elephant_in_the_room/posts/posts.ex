defmodule ElephantInTheRoom.Posts do
  import Ecto.Query, warn: false
  import Ecto.Changeset
  alias Ecto.Changeset
  alias ElephantInTheRoom.Posts.{Category, Featured, Post, Tag}
  alias ElephantInTheRoom.{Repo, Sites, Sites.Magazine, Sites.Site}
  alias ElephantInTheRoomWeb.PostView

  @default_post_preload [:author, :tags, :categories]

  def list_posts(site) do
    Post
    |> where([t], t.site_id == ^site.id)
    |> Repo.all()
    |> Repo.preload(:tags)
    |> Repo.preload(:categories)
  end

  def get_post!(site, id) do
    Post
    |> where([t], t.site_id == ^site.id)
    |> Repo.get!(id)
    |> Repo.preload(@default_post_preload)
  end

  def get_post!(id) do
    Post
    |> Repo.get!(id)
    |> Repo.preload(@default_post_preload)
  end

  def get_post_by_slug(site_id, slug, preload \\ @default_post_preload) do
    case Repo.get_by(Post, slug: slug, site_id: site_id) do
      nil ->
        {:error, :no_post_found}

      site ->
        {:ok, Repo.preload(site, preload)}
    end
  end

  def get_post_by_slug!(site_id, slug, preload \\ @default_post_preload) do
    Repo.get_by!(Post, slug: slug, site_id: site_id)
    |> Repo.preload(preload)
  end

  def create_post(%Site{id: site_id}, attrs) do
    post_attrs =
      Map.put(attrs, "site_id", site_id)
      |> Sites.ensure_author_exists

    inserted_post =
      %Post{}
      |> Post.changeset(post_attrs)
      |> Repo.insert()

    case inserted_post do
      {:ok, post} ->
        Post.increase_views_for_popular_by_1(post)
        Featured.invalidate_cache(site_id)
        inserted_post

      _ ->
        inserted_post
    end
  end

  def create_post(%Magazine{id: magazine_id}, attrs) do
    post_attrs =
      Map.put(attrs, "magazine_id", magazine_id)
      |> Sites.ensure_author_exists

    %Post{}
    |> Post.changeset(post_attrs)
    |> Repo.insert()
  end

  def create_magazine_post(attrs) do
    new_attrs = Sites.ensure_author_exists(attrs)

    %Post{}
    |> Post.changeset(new_attrs)
    |> Repo.insert()
  end

  def update_post(%Post{magazine_id: nil} = post, attrs) do
    Featured.invalidate_cache(post.site_id)

    post
    |> Post.changeset(Sites.ensure_author_exists(attrs))
    |> Repo.update()
  end

  def update_post(%Post{} = post, attrs) do
    post
    |> Post.changeset(Sites.ensure_author_exists(attrs))
    |> Repo.update()
  end

  def delete_post(%Post{magazine_id: nil} = post) do
    Featured.invalidate_cache(post.site_id)
    Repo.delete(post)
  end

  def delete_post(%Post{} = post) do
    Repo.delete(post)
  end

  def change_post(%Post{magazine_id: nil} = post) do
    Featured.invalidate_cache(post.site_id)
    Post.changeset(post, %{})
  end

  def change_post(%Post{} = post) do
    Post.changeset(post, %{})
  end

  def list_categories(site) do
    Category
    |> where([t], t.site_id == ^site.id)
    |> preload(:site)
    |> Repo.all()
  end

  def get_category!(site, id) do
    Category
    |> where([t], t.site_id == ^site.id)
    |> Repo.get!(id)
  end

  def get_category!(id), do: Repo.get!(Category, id)

  def get_category(id), do: Repo.get(Category, id)

  def create_category(site, attrs \\ %{}) do
    category_attrs = Map.put(attrs, "site_id", site.id)

    %Category{}
    |> Category.changeset(category_attrs)
    |> Repo.insert()
  end

  def update_category(%Category{} = category, attrs) do
    category
    |> Category.changeset(attrs)
    |> Repo.update()
  end

  def delete_category(%Category{} = category), do: Repo.delete(category)

  def change_category(%Category{} = category), do: Category.changeset(category, %{})

  def list_tags(site) do
    Tag
    |> where([t], t.site_id == ^site.id)
    |> preload(:site)
    |> Repo.all()
  end

  def get_tag!(site, id) do
    Tag
    |> where([t], t.site_id == ^site.id)
    |> Repo.get!(id)
  end

  def get_tag_by_name!(site_id, name) do
    Tag
    |> where([t], t.site_id == ^site_id and t.name == ^name)
    |> Repo.get_by!(%{name: name})
  end

  def create_tag(site, attrs) do
    tag_attrs = Map.put(attrs, "site_id", site.id)

    %Tag{}
    |> Tag.changeset(tag_attrs)
    |> Repo.insert()
  end

  def create_tag(attrs \\ %{}) do
    %Tag{}
    |> Tag.changeset(attrs)
    |> Repo.insert()
  end

  def update_tag(%Tag{} = tag, attrs) do
    tag
    |> Tag.changeset(attrs)
    |> Repo.update()
  end

  def delete_tag(%Tag{} = tag), do: Repo.delete(tag)

  def change_tag(%Tag{} = tag), do: Tag.changeset(tag, %{})

  def delete_cover(%Post{} = post) do
    post
    |> Post.changeset(%{"cover" => nil})
    |> Repo.update()
  end

  def gen_og_meta_for_post(
        conn,
        %Post{title: title, thumbnail: _image, abstract: description} = post
      ) do
    type = "article"
    title = "#{title} - #{conn.assigns.site.name}"

    url = PostView.show_link(conn, post)
    image = PostView.show_thumb_link(conn, post)

    if image != nil do
      %{url: url, type: type, title: title, description: description, image: image}
    else
      %{url: url, type: type, title: title, description: description}
    end
  end

  def to_slug(nil), do: ""

  def to_slug(name) do
    name
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9\s-]/, "")
    |> String.replace(~r/(\s|-)+/, "-")
  end

  def put_slugified_title(%Changeset{valid?: valid?} = changeset)
      when not valid?,
      do: changeset

  def put_slugified_field(%Changeset{} = changeset, field) when is_atom(field) do
    slug = get_field(changeset, :slug)

    if slug == nil || String.length(slug) == 0 do
      slug = get_field(changeset, field) |> to_slug()
      put_change(changeset, :slug, slug)
    else
      changeset
    end
  end

  def get_magazine_post_by_slug!(
        %Magazine{id: magazine_id},
        slug,
        preload \\ @default_post_preload
      ) do
    Repo.get_by!(Post, slug: slug, magazine_id: magazine_id)
    |> Repo.preload(preload)
  end

  def get_posts_paginated(%Site{id: site_id}, page) do
    case page do
      nil ->
        Post
        |> where([p], p.site_id == ^site_id)
        |> Repo.paginate(page: 1)

      page_number ->
        Post
        |> where([p], p.site_id == ^site_id)
        |> Repo.paginate(page: page_number)
    end
  end

  def get_posts_paginated(%Magazine{id: magazine_id}, page) do
    case page do
      nil ->
        Post
        |> where([p], p.magazine_id == ^magazine_id)
        |> Repo.paginate(page: 1)

      page_number ->
        Post
        |> where([p], p.magazine_id == ^magazine_id)
        |> Repo.paginate(page: page_number)
    end
  end
end
