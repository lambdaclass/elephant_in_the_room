defmodule ElephantInTheRoom.Sites do
  @moduledoc """
  The Sites context.
  """

  import Ecto.Query, warn: false
  alias ElephantInTheRoom.Repo

  alias ElephantInTheRoom.Sites.Site

  @doc """
  Returns the list of sites.

  ## Examples

      iex> list_sites()
      [%Site{}, ...]

  """
  def list_sites do
    Site |> Repo.all()
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
  def get_site!(id), do: Repo.get!(Site, id)

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

  alias ElephantInTheRoom.Sites.Category

  @doc """
  Returns the list of categories.

  ## Examples

      iex> list_categories(site)
      [%Category{}, ...]

  """
  def list_categories(site) do
    Category
    |> where([t], t.site_id == ^site.id)
    |> preload(:site_id)
    |> Repo.all()
  end

  @doc """
  Gets a single category.

  Raises `Ecto.NoResultsError` if the Category does not exist.

  ## Examples

      iex> get_category!(site, 123)
      %Category{}

      iex> get_category!(site, 456)
      ** (Ecto.NoResultsError)

      iex> get_category!(site, 123)
      %Category{}

      iex> get_category!(site, 456)
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
    category_attrs = Map.put(attrs, site.id)

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
    category
    |> Category.changeset(%{})
  end

  alias ElephantInTheRoom.Sites.Post

  @doc """
  Returns the list of posts.

  ## Examples

      iex> list_posts()
      [%Post{}, ...]

  """
  def list_posts(category) do
    Post
    |> where([t], t.category_id == ^category.id)
    |> Repo.all()
    |> preload(:category_id)
    |> preload(:site_id)
  end

  @doc """
  Gets a single post.

  Raises `Ecto.NoResultsError` if the Post does not exist.

  ## Examples

      iex> get_post!(123)
      %Post{}

      iex> get_post!(456)
      ** (Ecto.NoResultsError)

  """
  def get_post!(category, id) do
    Post
    |> where([t], t.category_id == ^category.id)
    |> Repo.get!(id)
  end

  def get_post!(id) do
    Post
    |> Repo.get!(id)
  end

  def get_post(id) do
    Post
    |> Repo.get(id)
  end

  @doc """
  Creates a post.

  ## Examples

      iex> create_post(%{field: value})
      {:ok, %Post{}}

      iex> create_post(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_post(site, attrs \\ %{}) do
    post_attrs = Map.put(attrs, site.id)

    %Post{}
    |> Post.changeset(post_attrs)
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
end
