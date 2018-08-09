defmodule ElephantInTheRoom.Sites do
  import Ecto.Query, warn: false
  alias ElephantInTheRoom.{Repo, Posts}
  alias ElephantInTheRoomWeb.{SiteView, Utils.Utils}
  alias ElephantInTheRoom.Posts.{Category, Post, Tag}
  alias ElephantInTheRoom.Sites.{Site, Author, Image}

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
    |> Ecto.Changeset.cast_assoc(:categories, with: &Category.changeset/2)
    |> Repo.insert()
  end

  def update_site(%Site{} = site, attrs) do
    site
    |> Site.changeset(attrs)
    |> Ecto.Changeset.cast_assoc(:categories, with: &Category.changeset/2)
    |> Repo.update()
  end

  def delete_site(%Site{} = site) do
    Repo.transaction(fn ->
      site.categories |> Enum.map(fn c -> Posts.delete_category(c) end)
      site.posts |> Enum.map(fn p -> Posts.delete_post(p) end)
      site.tags |> Enum.map(fn t -> Posts.delete_tag(t) end)
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
    %{page: page,
      amount: amount,
      bigger_amount: amount + 1,
      index: {index_from, index_to}}
  end

  def pagination_result(query_result, pagination) do
    query_reduced_result = Enum.take(query_result, pagination.amount)
    is_next_page = length(query_result) > pagination.amount
    is_previous_page = pagination.page >= 1
    %{result: query_reduced_result,
      page: pagination.page + 1,
      next_page: is_next_page,
      previous_page: is_previous_page}
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

  def ensure_author_exists(attrs) do
    case Author.ensure_author_exists(attrs["author_id"]) do
      {:ok, %Author{id: author_id}} ->
        %{attrs | "author_id" => author_id}

      _ ->
        attrs
    end
  end
end
