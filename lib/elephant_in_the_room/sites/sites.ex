defmodule ElephantInTheRoom.Sites do
  @moduledoc """
  The Sites context.
  """

  import Ecto.Query, warn: false
  import Ecto.Changeset
  alias Ecto.Changeset
  alias ElephantInTheRoom.Repo
  alias ElephantInTheRoom.Sites.{Site, Category, Post, Tag, Author, Image}

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

  @doc """
  Gets a single site.

  Raises `Ecto.NoResultsError` if the Site does not exist.

  ## Examples

      iex> get_site!(123)
      %Site{}

      iex> get_site!(456)
      ** (Ecto.NoResultsError)

  """

  @default_site_preload [:categories, [posts: :author], [posts: :categories], :tags]
  def get_site!(id) do
    Site
    |> Repo.get!(id)
    |> Repo.preload(@default_site_preload)
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
    |> Repo.preload(@default_post_preload )
  end

  def get_post!(id) do
    Post
    |> Repo.get!(id)
    |> Repo.preload(@default_post_preload )
  end

  def get_post_by_slug(site_id, slug, preload \\ @default_post_preload ) do
    case Repo.get_by(Post, slug: slug, site_id: site_id) do
      nil -> {:error, :no_post_found}
      site ->
        {:ok, Repo.preload(site, preload)}
    end
  end

  @doc """
  Creates a post.

  ## Examples

      iex> create_post(%{field: value})
      {:ok, %Post{}}

      iex> create_post(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """

  def create_post(site, attrs) do
    post_attrs = Map.put(attrs, "site_id", site.id)

    %Post{}
    |> Post.changeset(post_attrs)
    |> Repo.insert()
  end

  def create_post(attrs \\ %{}) do
    %Post{}
    |> Post.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a post.

  ## Examples

      iex> update_post(post, %{field: new_value})
      {:ok, %Post{}}

      iex> update_post(post, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_post(%Post{} = post, attrs) do
    post
    |> Post.changeset(attrs)
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
  def delete_post(%Post{} = post) do
    Repo.delete(post)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking post changes.

  ## Examples

      iex> change_post(post)
      %Ecto.Changeset{source: %Post{}}

  """
  def change_post(%Post{} = post) do
    Post.changeset(post, %{})
  end

  def delete_cover(%Post{} = post) do
    Ecto.Changeset.change(post, cover: nil)
    |> Repo.update()
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
end
