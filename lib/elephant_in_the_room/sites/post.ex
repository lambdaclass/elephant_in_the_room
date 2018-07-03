defmodule ElephantInTheRoom.Sites.Post do
  use Ecto.Schema
  use Arc.Ecto.Schema
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
    field(:image, Image.Type)
    field(:cover, :boolean)

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
    new_attrs = Map.put(attrs, "image", image_hash_name(attrs["image"]))

    post
    |> cast(new_attrs, [:title, :content, :slug, :abstract, :site_id, :author_id, :cover])
    |> cast_attachments(new_attrs, [:image], [])
    |> put_assoc(:tags, parse_tags(new_attrs))
    |> put_assoc(:categories, parse_categories(new_attrs))
    |> validate_required([:title, :content, :site_id, :image, :cover])
    |> put_rendered_content
    |> put_slugified_title
  end

  def image_hash_name(%Plug.Upload{filename: filename} = upload) do
    extension =
      filename
      |> String.split(".")
      |> List.last()

    %{upload | filename: Ecto.UUID.generate()}
  end

  def image_hash_name(image) do
    image
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

  defp calculate_occurrences(n, slug, suffix) do
    case Repo.get_by(Post, slug: slug <> suffix) do
      nil -> n
      %Post{} -> calculate_occurrences(n + 1, slug, "-#{n + 1}")
    end
  end

  def put_slugified_title(%Changeset{valid?: valid?} = changeset)
      when not valid? do
    changeset
  end

  def put_slugified_title(%Changeset{} = changeset) do
    slug = get_field(changeset, :slug)

    if slug == nil || String.length(slug) == 0 do
      slug = get_field(changeset, :title) |> Sites.to_slug()

      case calculate_occurrences(0, slug, "") do
        0 -> put_change(changeset, :slug, slug)
        n -> put_change(changeset, :slug, slug <> "-#{n}")
      end
    else
      changeset
    end
  end

  def generate_markdown(input) do
    {:safe, safe_input} = Phoenix.HTML.html_escape(input)
    Cmark.to_html(safe_input)
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

    (params["tags_separated_by_comma"] || "")
    |> String.split(",")
    |> Enum.map(&String.trim/1)
    |> Enum.reject(fn s -> s == "" end)
    |> Enum.uniq()
    |> Enum.map(fn name -> get_or_insert_tag(name, site_id) end)
  end

  defp get_or_insert_tag(name, site_id) do
    Repo.insert!(
      %Tag{name: name, site_id: site_id},
      on_conflict: [set: [name: name, site_id: site_id]],
      conflict_target: :name
    )
  end
end
