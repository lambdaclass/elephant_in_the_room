defmodule ElephantInTheRoom.Sites do
  @moduledoc """
  The Sites context.
  """

  import Ecto.Query, warn: false
  import Ecto.Changeset
  alias Ecto.Changeset
  alias ElephantInTheRoom.Repo
  alias ElephantInTheRoomWeb.{PostView, SiteView, Utils.Utils}
  alias ElephantInTheRoom.Sites.{Author, Category, Featured, Image, Magazine, Post, Site, Tag}

  @doc """
  Returns the list of sites.

  ## Examples

      iex> list_sites()
      [%Site{}, ...]

  """
  def list_sites do
    Site
    |> Repo.all()
    |> Repo.preload([:categories, :posts, :tags])
  end

  def list_site_no_preload, do: Repo.all(Site)

  @doc """
  Gets a single site.

  Raises `Ecto.NoResultsError` if the Site does not exist.

  ## Examples

      iex> get_site!(123)
      %Site{}

      iex> get_site!(456)
      ** (Ecto.NoResultsError)

  """

  def default_site_preload() do
    [
      :categories,
      {:posts, from(p in Post, order_by: p.inserted_at)},
      [posts: :author],
      [posts: :categories],
      :authors,
      :tags
    ]
  end

  @default_site_preload [
    :categories,
    {:posts, from(p in Post, order_by: p.inserted_at)},
    [posts: :author],
    [posts: :categories],
    :authors,
    :tags
  ]

  def get_site!(id) do
    Site
    |> Repo.get!(id)
    |> Repo.preload(default_site_preload())
  end

  def get_site(id, preload \\ @default_site_preload) do
    case Repo.get(Site, id) do
      nil -> {:error, :no_site_found}
      site -> {:ok, Repo.preload(site, preload)}
    end
  end

  def get_site_by_name(site_name) do
    case Repo.get_by(Site, name: site_name) do
      nil -> {:error, :not_found}
      site -> {:ok, site}
    end
  end

  def get_site_by_name!(site_name, preload \\ @default_site_preload) do
    Site
    |> Repo.get_by!(name: URI.decode(site_name))
    |> Repo.preload(preload)
  end

  @doc """
  Creates a site.

  ## Examples

      iex> create_site(%{field: value})
      {:ok, %Site{}}

      iex> create_site(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_site(attrs \\ %{}) do
    %Site{}
    |> Site.changeset(attrs)
    |> Ecto.Changeset.cast_assoc(:categories, with: &Category.changeset/2)
    |> Repo.insert()
  end

  @doc """
  Updates a site.

  ## Examples

      iex> update_site(site, %{field: new_value})
      {:ok, %Site{}}

      iex> update_site(site, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_site(%Site{} = site, attrs) do
    site
    |> Site.changeset(attrs)
    |> Ecto.Changeset.cast_assoc(:categories, with: &Category.changeset/2)
    |> Repo.update()
  end

  @doc """
  Deletes a Site.

  ## Examples

      iex> delete_site(site)
      {:ok, %Site{}}

      iex> delete_site(site)
      {:error, %Ecto.Changeset{}}

  """
  def delete_site(%Site{} = site) do
    Repo.transaction(fn ->
      site.categories |> Enum.map(fn c -> delete_category(c) end)
      site.posts |> Enum.map(fn p -> delete_post(p) end)
      site.tags |> Enum.map(fn t -> delete_tag(t) end)
    end)

    Repo.delete(site)
  end

  def delete_site_field(%Site{} = site, field) do
    site
    |> Site.changeset(%{"#{field}" => nil})
    |> Repo.update()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking site changes.

  ## Examples

      iex> change_site(site)
      %Ecto.Changeset{source: %Site{}}

  """
  def change_site(%Site{} = site) do
    Site.changeset(site, %{})
  end

  @doc """
  Returns the list of categories.

  ## Examples

      iex> list_categories()
      [%Category{}, ...]

  """
  def list_categories(site) do
    Category
    |> where([t], t.site_id == ^site.id)
    |> preload(:site)
    |> Repo.all()
  end

  @doc """
  Gets a single category.

  Raises `Ecto.NoResultsError` if the Category does not exist.

  ## Examples

      iex> get_category!(123)
      %Category{}

      iex> get_category!(456)
      ** (Ecto.NoResultsError)

  """
  def get_category!(site, id) do
    Category
    |> where([t], t.site_id == ^site.id)
    |> Repo.get!(id)
  end

  def get_category!(id) do
    Category
    |> Repo.get!(id)
  end

  def get_category(id) do
    Category
    |> Repo.get(id)
  end

  @doc """
  Creates a category.

  ## Examples

      iex> create_category(%{field: value})
      {:ok, %Category{}}

      iex> create_category(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_category(site, attrs \\ %{}) do
    category_attrs = Map.put(attrs, "site_id", site.id)

    %Category{}
    |> Category.changeset(category_attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a category.

  ## Examples

      iex> update_category(category, %{field: new_value})
      {:ok, %Category{}}

      iex> update_category(category, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_category(%Category{} = category, attrs) do
    category
    |> Category.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Category.

  ## Examples

      iex> delete_category(category)
      {:ok, %Category{}}

      iex> delete_category(category)
      {:error, %Ecto.Changeset{}}

  """
  def delete_category(%Category{} = category) do
    Repo.delete(category)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking category changes.

  ## Examples

      iex> change_category(category)
      %Ecto.Changeset{source: %Category{}}

  """
  def change_category(%Category{} = category) do
    Category.changeset(category, %{})
  end

  def gen_og_meta_for_site(conn) do
    [url, image] =
      [SiteView.show_site_link(conn), conn.assigns.site.image]
      |> Enum.map(fn path -> Utils.generate_absolute_url(path, conn) end)

    meta_tags = %{
      url: url,
      type: "website",
      title: "#{conn.assigns.site.title}",
      description: conn.assigns.site.description
    }

    if conn.assigns.site.image do
      Map.put(meta_tags, :image, image)
    else
      meta_tags
    end
  end

  @doc """
  Returns the list of posts.

  ## Examples

      iex> list_posts()
      [%Post{}, ...]

  """
  def list_posts(site) do
    Post
    |> where([t], t.site_id == ^site.id)
    |> Repo.all()
    |> Repo.preload(:tags)
    |> Repo.preload(:categories)
  end

  @doc """
  Gets a single post.
  Raises `Ecto.NoResultsError` if the Post does not exist.
  """
  @default_post_preload [:author, :tags, :categories]
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

  def get_post_by_slug!(site_id, slug, preload \\ @default_post_preload) do
    Repo.get_by!(Post, slug: slug, site_id: site_id)
    |> Repo.preload(preload)
  end

  def get_magazine_post_by_slug!(%Magazine{id: magazine_id}, slug, preload \\ @default_post_preload) do
    Repo.get_by!(Post, slug: slug, magazine_id: magazine_id)
    |> Repo.preload(preload)
  end

  def pagination_opts(opts) do
    page = Keyword.get(opts, :page, 1) - 1
    amount = Keyword.get(opts, :amount, 10)
    bigger_amount = amount + 1
    index_from = page * amount
    index_to = index_from + amount - 1
    %{page: page, amount: amount, bigger_amount: bigger_amount, index: {index_from, index_to}}
  end

  def pagination_result(query_result, pagination) do
    query_reduced_result = Enum.take(query_result, pagination.amount)
    query_result_size = length(query_result)
    is_next_page = query_result_size > pagination.amount
    is_previous_page = pagination.page >= 1

    %{
      result: query_reduced_result,
      page: pagination.page + 1,
      next_page: is_next_page,
      previous_page: is_previous_page
    }
  end

  def get_popular_posts(%Site{id: site_id}, opts \\ []) do
    %{index: {index_from, index_to}} = pagination_opts(opts)
    get_popular_posts_from_db(site_id, index_from, index_to)
  end

  def get_popular_posts_from_db(site_id, index_from, index_to) do
    {:ok, data} =
      Redix.command(
        :redix,
        ["ZREVRANGE", "site:#{site_id}", index_from, index_to, "WITHSCORES"]
      )

    scores =
      Enum.chunk(data, 2)
      |> Enum.map(fn [id, score] -> {id, String.to_integer(score)} end)
      |> Map.new()

    Post
    |> where([post], post.id in ^Map.keys(scores))
    |> Repo.all()
    |> Repo.preload(:author)
    |> Enum.sort_by(&scores[&1.id], &>=/2)
  end

  def get_latest_posts(%Site{id: site_id}, opts \\ []) do
    %{index: {index_from, _}, amount: amount} = pagination_opts(opts)

    query =
      from(
        post in Post,
        where: post.site_id == ^site_id,
        order_by: [desc: post.inserted_at],
        offset: ^index_from,
        limit: ^amount,
        preload: [:author]
      )

    Repo.all(query)
  end

  def get_category_with_posts(%Site{id: site_id}, category_id, opts \\ []) do
    %{index: {index_from, _}, amount: amount} = pagination_opts(opts)

    posts =
      from(
        c in Category,
        where: c.id == ^category_id and c.site_id == ^site_id,
        left_join: posts_categories in "posts_categories",
        where: c.id == posts_categories.category_id,
        left_join: p in Post,
        where: p.id == posts_categories.post_id,
        offset: ^index_from,
        limit: ^amount,
        select: p
      )

    Repo.preload(Repo.all(posts), [:author])
  end

  def get_tag_with_posts(%Site{id: site_id}, tag_id, opts \\ []) do
    %{index: {index_from, _}, amount: amount} = pagination_opts(opts)

    posts =
      from(
        t in Tag,
        where: t.id == ^tag_id and t.site_id == ^site_id,
        left_join: posts_tags in "posts_tags",
        where: t.id == posts_tags.tag_id,
        left_join: p in Post,
        where: p.id == posts_tags.post_id,
        offset: ^index_from,
        limit: ^amount,
        select: p
      )

    Repo.preload(Repo.all(posts), [:author])
  end

  def get_columnists(%Site{} = site, amount) do
    Ecto.assoc(site, :authors)
    |> where([author], author.is_columnist == true)
    |> distinct(true)
    |> limit(^amount)
    |> Repo.all()
  end

  def get_columnists_and_posts(%{id: site_id}, amount) do
    query =
      from(
        post in Post,
        where: post.site_id == ^site_id,
        order_by: [desc: post.inserted_at],
        distinct: post.author_id,
        left_join: author in Author,
        on: post.author_id == author.id,
        limit: ^amount,
        where: author.is_columnist == true,
        select: %{
          author: author,
          post: post
        }
      )

    Repo.all(query) |> Enum.reverse()
  end

  @doc """
  Creates a post.

  ## Examples

      iex> create_post(%{field: value})
      {:ok, %Post{}}

      iex> create_post(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """

  def create_post(%Site{id: site_id}, attrs) do
    post_attrs =
      Map.put(attrs, "site_id", site_id)
      |> ensure_author_exists

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
      |> ensure_author_exists

    %Post{}
    |> Post.changeset(post_attrs)
    |> Repo.insert()
  end

  def create_magazine_post(attrs) do
    new_attrs = ensure_author_exists(attrs)

    %Post{}
    |> Post.changeset(new_attrs)
    |> Repo.insert
  end

  def ensure_author_exists(attrs) do
    case Author.ensure_author_exists(attrs["author_id"]) do
      {:ok, %Author{id: author_id}} ->
        %{attrs | "author_id" => author_id}

      _ ->
        attrs
    end
  end

  @doc """
  Updates a post.

  ## Examples

      iex> update_post(post, %{field: new_value})
      {:ok, %Post{}}

      iex> update_post(post, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_post(%Post{magazine_id: nil} = post, attrs) do
    post
    |> Post.changeset(ensure_author_exists(attrs))
    |> Repo.update()
  end

  def update_post(%Post{} = post, attrs) do
    post
    |> Post.changeset(ensure_author_exists(attrs))
    |> Repo.update()
  end

  @doc """
  Deletes a Post.

  ## Examples

      iex> delete_post(post)
      {:ok, %Post{}}

      iex> delete_post(post)
      {:error, %Ecto.Changeset{}}

  """
  def delete_post(%Post{magazine_id: nil} = post) do
    Repo.delete(post)
  end

  def delete_post(%Post{} = post) do
    Repo.delete(post)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking post changes.

  ## Examples

      iex> change_post(post)
      %Ecto.Changeset{source: %Post{}}

  """
  def change_post(%Post{magazine_id: nil} = post) do
    Post.changeset(post, %{})
  end

  def change_post(%Post{magazine_id: _mag_id} = post) do
    Post.changeset(post, %{})
  end

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

  @doc """
  Returns the list of tags.

  ## Examples
  def get_tag!(id), do: Repo.get!(Tag, id)
      iex> list_tags()
      [%Tag{}, ...]

  """
  def list_tags(site) do
    Tag
    |> where([t], t.site_id == ^site.id)
    |> preload(:site)
    |> Repo.all()
  end

  @doc """
  Gets a single tag.

  Raises `Ecto.NoResultsError` if the Tag does not exist.

  ## Examples

      iex> get_tag!(123)
      %Tag{}

      iex> get_tag!(456)
      ** (Ecto.NoResultsError)

  """
  def get_tag!(id), do: Repo.get!(Tag, id)

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

  @doc """
  Creates a tag.

  ## Examples

      iex> create_tag(%{field: value})
      {:ok, %Tag{}}

      iex> create_tag(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
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

  @doc """
  Updates a tag.

  ## Examples

      iex> update_tag(tag, %{field: new_value})
      {:ok, %Tag{}}

      iex> update_tag(tag, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_tag(%Tag{} = tag, attrs) do
    tag
    |> Tag.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Tag.

  ## Examples

      iex> delete_tag(tag)
      {:ok, %Tag{}}

      iex> delete_tag(tag)
      {:error, %Ecto.Changeset{}}

  """
  def delete_tag(%Tag{} = tag) do
    Repo.delete(tag)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking tag changes.

  ## Examples

      iex> change_tag(tag)
      %Ecto.Changeset{source: %Tag{}}

  """
  def change_tag(%Tag{} = tag) do
    Tag.changeset(tag, %{})
  end

  @doc """
  Deletes a Author.

  ## Examples

      iex> delete_author(author)
      {:ok, %Author{}}

      iex> delete_author(author)
      {:error, %Ecto.Changeset{}}

  """
  def delete_author(%Author{} = author) do
    Repo.delete(author)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking author changes.

  ## Examples

      iex> change_author(author)
      %Ecto.Changeset{source: %Author{}}

  """
  def change_author(%Author{} = author) do
    Author.changeset(author, %{})
  end

  @doc """
  Returns the list of authors.

  ## Examples

      iex> list_authors()
      [%Author{}, ...]

  """
  def list_authors do
    Repo.all(Author)
  end

  @doc """
  Gets a single author.

  Raises `Ecto.NoResultsError` if the Author does not exist.

  ## Examples

      iex> get_author!(123)
      %Author{}

      iex> get_author!(456)
      ** (Ecto.NoResultsError)

  """
  def get_author!(id) do
    Repo.get!(Author, id)
  end

  @doc """
  Creates a author.

  ## Examples

      iex> create_author(%{field: value})
      {:ok, %Author{}}

      iex> create_author(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_author(attrs \\ %{}) do
    %Author{}
    |> Author.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a author.

  ## Examples

      iex> update_author(author, %{field: new_value})
      {:ok, %Author{}}

      iex> update_author(author, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_author(%Author{} = author, attrs) do
    author
    |> Author.changeset(attrs)
    |> Repo.update()
  end

  def to_slug(nil), do: ""

  def to_slug(name) do
    name
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9\s-]/, "")
    |> String.replace(~r/(\s|-)+/, "-")
  end

  def put_slugified_title(%Changeset{valid?: valid?} = changeset)
      when not valid? do
    changeset
  end

  def put_slugified_field(%Changeset{} = changeset, field) when is_atom(field) do
    slug = get_field(changeset, :slug)

    if slug == nil || String.length(slug) == 0 do
      slug = get_field(changeset, field) |> to_slug()
      put_change(changeset, :slug, slug)
    else
      changeset
    end
  end

  @doc """
  Returns the list of images.

  ## Examples

      iex> list_images()
      [%Image{}, ...]

  """
  def list_images do
    Repo.all(Image)
  end

  @doc """
  Gets a single image.

  Raises `Ecto.NoResultsError` if the Image does not exist.

  ## Examples

      iex> get_image!(123)
      %Image{}

      iex> get_image!(456)
      ** (Ecto.NoResultsError)

  """
  def get_image!(id), do: Repo.get!(Image, id)

  def get_image_by_name!(name), do: Repo.get_by!(Image, name: name)

  @doc """
  Creates a image.

  ## Examples

      iex> create_image(%{field: value})
      {:ok, %Image{}}

      iex> create_image(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_image(attrs \\ %{}) do
    %Image{}
    |> Image.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a image.

  ## Examples

      iex> update_image(image, %{field: new_value})
      {:ok, %Image{}}

      iex> update_image(image, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_image(%Image{} = image, attrs) do
    image
    |> Image.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Image.

  ## Examples

      iex> delete_image(image)
      {:ok, %Image{}}

      iex> delete_image(image)
      {:error, %Ecto.Changeset{}}

  """
  def delete_image(%Image{} = image) do
    Repo.delete(image)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking image changes.

  ## Examples

      iex> change_image(image)
      %Ecto.Changeset{source: %Image{}}

  """
  def change_image(%Image{} = image) do
    Image.changeset(image, %{})
  end

  @doc """
  Returns the list of magazines.

  ## Examples

      iex> list_magazines()
      [%Magazine{}, ...]

  """
  def list_magazines(site, page) do
    page_number = if page, do: page, else: 0
    Magazine
    |> where([m], m.site_id == ^site.id)
    |> order_by(desc: :inserted_at)
    |> Repo.paginate(page: page_number)
  end

  @doc """
  Gets a single magazine.

  Raises `Ecto.NoResultsError` if the Magazine does not exist.

  ## Examples

      iex> get_magazine!(123)
      %Magazine{}

      iex> get_magazine!(456)
      ** (Ecto.NoResultsError)

  """
  def get_magazine(magazine_id, preloads \\ []) do
    Repo.get(Magazine, magazine_id)
    |> Repo.preload(preloads)
  end

  def get_magazine!(title, site_id, preloads \\ []) do
    Repo.get_by!(Magazine, site_id: site_id, title: title)
    |> Repo.preload(preloads)
  end

  def get_current_magazine(site_id, preloads) do
    [current] = Magazine
      |> where(site_id: ^site_id)
      |> order_by(desc: :inserted_at)
      |> limit(1)
      |> Repo.all()

    current
    |> Repo.preload(preloads)
  end
  @doc """
  Creates a magazine.

  ## Examples

      iex> create_magazine(%{field: value})
      {:ok, %Magazine{}}

      iex> create_magazine(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_magazine(attrs \\ %{}) do
    %Magazine{}
    |> Magazine.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a magazine.

  ## Examples

      iex> update_magazine(magazine, %{field: new_value})
      {:ok, %Magazine{}}

      iex> update_magazine(magazine, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_magazine(%Magazine{} = magazine, attrs) do
    magazine
    |> Magazine.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Magazine.

  ## Examples

      iex> delete_magazine(magazine)
      {:ok, %Magazine{}}

      iex> delete_magazine(magazine)
      {:error, %Ecto.Changeset{}}

  """
  def delete_magazine(%Magazine{} = magazine) do
    Repo.delete(magazine)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking magazine changes.

  ## Examples

      iex> change_magazine(magazine)
      %Ecto.Changeset{source: %Magazine{}}

  """
  def change_magazine(%Magazine{} = magazine) do
    Magazine.changeset(magazine, %{})
  end

  def get_by_name!(name, model) do
    Repo.get_by!(model, name: name)
  end

  def get_by_name!(name, site_id, model) do
    Repo.get_by!(model, name: name, site_id: site_id)
  end

  def get_by_name(name, model) do
    Repo.get_by(model, name: name)
  end

  def from_name!(name, model) do
    name
    |> URI.decode()
    |> get_by_name!(model)
  end

  def from_name!(name, site_id, model) do
    name
    |> URI.decode()
    |> get_by_name!(site_id, model)
  end
end
