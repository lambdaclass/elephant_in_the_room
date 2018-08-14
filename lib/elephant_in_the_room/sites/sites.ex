defmodule ElephantInTheRoom.Sites do
  import Ecto.Query, warn: false
  alias Ecto.Changeset
  alias ElephantInTheRoom.Posts
  alias ElephantInTheRoom.Posts.{Category, Post, Tag}
  alias ElephantInTheRoom.Repo
  alias ElephantInTheRoom.Sites.{Author, Feedback, Image, Magazine, Site}
  alias ElephantInTheRoomWeb.{SiteView, Utils.Utils}

  @default_site_preload [
    :categories,
    {:posts, from(p in Post, order_by: p.inserted_at)},
    [posts: :author],
    [posts: :categories],
    :authors,
    :tags
  ]

  def list_sites do
    Site
    |> Repo.all()
    |> Repo.preload([:categories, :posts, :tags])
  end

  def list_site_no_preload, do: Repo.all(Site)

  def default_site_preload do
    [
      :categories,
      {:posts, from(p in Post, order_by: p.inserted_at)},
      [posts: :author],
      [posts: :categories],
      :authors,
      :tags
    ]
  end

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

  def create_site(attrs \\ %{}) do
    %Site{}
    |> Site.changeset(attrs)
    |> Changeset.cast_assoc(:categories, with: &Category.changeset/2)
    |> Repo.insert()
  end

  def update_site(%Site{} = site, attrs) do
    site
    |> Site.changeset(attrs)
    |> Changeset.cast_assoc(:categories, with: &Category.changeset/2)
    |> Repo.update()
  end

  def delete_site(%Site{} = site) do
    Repo.transaction(fn ->
      site.categories |> Enum.each(fn c -> Posts.delete_category(c) end)
      site.posts |> Enum.each(fn p -> Posts.delete_post(p) end)
      site.tags |> Enum.each(fn t -> Posts.delete_tag(t) end)
    end)

    Repo.delete(site)
  end

  def delete_site_field(%Site{} = site, field) do
    site
    |> Site.changeset(%{"#{field}" => nil})
    |> Repo.update()
  end

  def change_site(%Site{} = site), do: Site.changeset(site, %{})

  def delete_author(%Author{} = author), do: Repo.delete(author)

  def change_author(%Author{} = author), do: Author.changeset(author, %{})

  def list_authors, do: Repo.all(Author)

  def get_author!(id), do: Repo.get!(Author, id)

  def create_author(attrs \\ %{}) do
    %Author{}
    |> Author.changeset(attrs)
    |> Repo.insert()
  end

  def update_author(%Author{} = author, attrs) do
    author
    |> Author.changeset(attrs)
    |> Repo.update()
  end

  def list_images, do: Repo.all(Image)

  def get_image!(id), do: Repo.get!(Image, id)

  def get_image_by_name!(name), do: Repo.get_by!(Image, name: name)

  def create_image(attrs \\ %{}) do
    %Image{}
    |> Image.changeset(attrs)
    |> Repo.insert()
  end

  def update_image(%Image{} = image, attrs) do
    image
    |> Image.changeset(attrs)
    |> Repo.update()
  end

  def delete_image(%Image{} = image), do: Repo.delete(image)

  def change_image(%Image{} = image), do: Image.changeset(image, %{})

  def get_by_name!(name, model), do: Repo.get_by!(model, name: name)

  def get_by_name!(name, site_id, model),
    do: Repo.get_by!(model, name: name, site_id: site_id)

  def get_by_name(name, model), do: Repo.get_by(model, name: name)

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

  def pagination_opts(opts) do
    page = Keyword.get(opts, :page, 1) - 1
    amount = Keyword.get(opts, :amount, 10)
    index_from = page * amount
    index_to = index_from + amount - 1
    %{page: page, amount: amount, bigger_amount: amount + 1, index: {index_from, index_to}}
  end

  def pagination_result(query_result, pagination) do
    query_reduced_result = Enum.take(query_result, pagination.amount)
    is_next_page = length(query_result) > pagination.amount
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

  def get_media_posts(%Site{id: site_id}) do
    query =
      from(p in Post,
        where: p.site_id == ^site_id and p.type != "text",
        select: p
      )

    query
    |> Repo.all()
    |> Repo.preload([:author])
  end

  def get_popular_posts_from_db(site_id, index_from, index_to) do
    {:ok, data} =
      Redix.command(
        :redix,
        ["ZREVRANGE", "site:#{site_id}", index_from, index_to, "WITHSCORES"]
      )

    scores =
      data
      |> Enum.chunk_every(2)
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

  def ensure_author_exists(attrs) do
    case Author.ensure_author_exists(attrs["author_id"]) do
      {:ok, %Author{id: author_id}} ->
        %{attrs | "author_id" => author_id}

      _ ->
        attrs
    end
  end

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
    [current] =
      Magazine
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
      {:error, %Changeset{}}

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
      {:error, %Changeset{}}

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
      {:error, %Changeset{}}

  """
  def delete_magazine(%Magazine{} = magazine) do
    Repo.delete(magazine)
  end

  @doc """
  Returns an `%Changeset{}` for tracking magazine changes.

  ## Examples

      iex> change_magazine(magazine)
      %Changeset{source: %Magazine{}}
  """
  def change_magazine(%Magazine{} = magazine) do
    Magazine.changeset(magazine, %{})
  end

  def list_feedbacks(site) do
    Feedback
    |> where([f], f.site_id == ^site.id)
    |> preload(:site)
    |> Repo.all()
  end

  def get_feedback!(site, id) do
    Feedback
    |> where([f], f.site_id == ^site.id)
    |> Repo.get!(id)
  end

  def create_feedback(site, attrs) do
    feedback_attrs = Map.put(attrs, "site_id", site.id)

    %Feedback{}
    |> Feedback.changeset(feedback_attrs)
    |> Repo.insert()
  end

  def update_feedback(%Feedback{} = feedback, attrs) do
    feedback
    |> Feedback.changeset(attrs)
    |> Repo.update()
  end

  def delete_feedback(%Feedback{} = feedback) do
    Repo.delete(feedback)
  end

  def change_feedback(%Feedback{} = feedback) do
    Feedback.changeset(feedback, %{})
  end
end
