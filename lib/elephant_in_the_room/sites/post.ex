defmodule ElephantInTheRoom.Sites.Post do
  use Ecto.Schema
  import Ecto.Changeset
  alias Ecto.Changeset
  alias ElephantInTheRoom.Sites.{Post, Site, Category, Tag, Author}
  alias ElephantInTheRoom.{Repo, Sites}
  alias ElephantInTheRoomWeb.Uploaders.Image

  schema "posts" do
    field(:title, :string)
    field(:slug, :string)
    field(:abstract, :string)
    field(:content, :string)
    field(:rendered_content, :string)
    field(:cover, :string)
    field(:thumbnail, :string)

    belongs_to(:site, Site, foreign_key: :site_id)
    belongs_to(:author, Author, on_replace: :nilify)

    many_to_many(
      :categories,
      Category,
      join_through: "posts_categories",
      on_replace: :delete,
      on_delete: :delete_all
    )

    many_to_many(
      :tags,
      Tag,
      join_through: "posts_tags",
      on_replace: :delete,
      on_delete: :delete_all
    )

    timestamps()
  end

  @doc false
  def changeset(%Post{} = post, attrs) do
    post
    |> cast(attrs, [:title, :content, :slug, :abstract, :site_id, :author_id])
    |> put_assoc(:tags, parse_tags(attrs))
    |> put_assoc(:categories, parse_categories(attrs))
    |> validate_required([:title, :content, :site_id])
    |> put_rendered_content
    |> put_slugified_title
    |> unique_constraint(:slug, name: :slug_unique_index)
    |> store_cover(attrs)
    |> set_thumbnail
  end

  def store_cover(%Changeset{valid?: false} = changeset, _attrs) do
    changeset
  end

  def store_cover(%Changeset{} = changeset, %{"cover" => nil}) do
    put_change(changeset, :cover, nil)
  end

  def store_cover(%Changeset{} = changeset, %{"cover" => cover}) do
    {:ok, cover_name} = Image.store(%{cover | filename: Ecto.UUID.generate()})

    put_change(changeset, :cover, "/images/" <> cover_name)
  end

  def store_cover(%Changeset{} = changeset, _attrs) do
    changeset
  end

  def set_thumbnail(%Changeset{valid?: false} = changeset) do
    changeset
  end

  def set_thumbnail(%Changeset{} = changeset) do
    url = case get_field(changeset, :cover) do
      nil ->
        case Regex.run(~r/src="\S+"/, get_field(changeset, :rendered_content)) do
          nil ->
            "http://cdn.gearpatrol.com/wp-content/uploads/2015/12/grey_placeholder.jpg"
          [img] ->
            img
            |> String.split("\"")
            |> Enum.at(1)
        end
      cover ->
        cover
    end
    put_change(changeset, :thumbnail, url)
  end

  def put_rendered_content(%Changeset{valid?: valid?} = changeset)
      when not valid? do
    changeset
  end

  def put_rendered_content(%Changeset{} = changeset) do
    content = get_field(changeset, :content)
    rendered_content = generate_markdown(content)

    put_change(changeset, :rendered_content, rendered_content)
    |> validate_length(:rendered_content, min: 1)
  end

  defp calculate_occurrences(slug, site_id) do
    site = Sites.get_site!(site_id)

    site.posts
    |> Enum.count(fn post -> post.slug == slug end)
  end

  def put_slugified_title(%Changeset{valid?: valid?} = changeset)
      when not valid? do
    changeset
  end

  def put_slugified_title(%Changeset{} = changeset) do
    site_id = get_field(changeset, :site_id)
    slug = get_field(changeset, :slug)

    if slug == nil || String.length(slug) == 0 do
      slug = get_field(changeset, :title) |> Sites.to_slug()
    end

    case calculate_occurrences(slug, site_id) do
      0 -> put_change(changeset, :slug, slug)
      n -> put_change(changeset, :slug, slug <> "-#{n}")
    end
  end

  def generate_markdown(input) do
    Cmark.to_html(input, [:safe])
  end

  def parse_categories(params) do
    site_id = params["site_id"]

    (params["categories"] || [])
    |> Enum.reject(fn s -> s == "" end)
    |> Enum.map(fn name -> get_category(name, site_id) end)
  end

  defp get_category(name, site_id) do
    Repo.get_by!(Category, name: name, site_id: site_id)
  end

  defp parse_tags(params) do
    site_id = params["site_id"]

    (params["tags"] || [])
    |> Enum.reject(fn s -> s == "" end)
    |> Enum.uniq()
    |> Enum.map(&get_or_insert_tag(&, site_id))
  end

  defp get_or_insert_tag(name, site_id) do
    Repo.insert!(
      %Tag{name: name, site_id: site_id},
      on_conflict: [set: [name: name, site_id: site_id]],
      conflict_target: :name
    )
  end
end
