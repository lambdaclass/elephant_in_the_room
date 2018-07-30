defmodule ElephantInTheRoom.Sites.Post do
  use ElephantInTheRoom.Schema
  import Ecto.Changeset
  alias Ecto.Changeset
  alias ElephantInTheRoom.Sites.{Post, Site, Category, Tag, Author}
  alias ElephantInTheRoom.{Repo, Sites}
  alias ElephantInTheRoomWeb.{PostView, Uploaders.Image}

  schema "posts" do
    field(:title, :string)
    field(:slug, :string)
    field(:abstract, :string)
    field(:content, :string)
    field(:rendered_content, :string)
    field(:cover, :string)
    field(:thumbnail, :string)
    field(:featured_level, :integer, default: 0)

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
    new_attrs =
      attrs
      |> parse_date()
      |> put_site_id()

    post
    |> cast(new_attrs, [:title, :content, :slug, :inserted_at, :abstract, :site_id, :author_id, :featured_level])
    |> put_assoc(:tags, parse_tags(attrs))
    |> put_assoc(:categories, parse_categories(attrs))
    |> validate_required([:title, :content, :site_id])
    |> put_rendered_content
    |> unique_slug_constraint
    |> store_cover(attrs)
    |> set_thumbnail
  end


  def put_site_id(%{site_name: site_name}) do
    Sites.get_site_by_name!(site_name)
  end
  def put_site_id(attrs), do: attrs
  def unique_slug_constraint(changeset) do
    put_slugified_title(changeset)
    |> unique_constraint(:slug, name: :slug_unique_index)
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
    url =
      case get_field(changeset, :cover) do
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

  def put_slugified_title(%Changeset{valid?: valid?} = changeset)
      when not valid? do
    changeset
  end

  def put_slugified_title(%Changeset{} = changeset) do
    slug = get_field(changeset, :slug)

    slug =
      if slug == nil || String.length(slug) == 0 do
        get_field(changeset, :title) |> Sites.to_slug()
      else
        slug
      end

    put_change(changeset, :slug, slug)
  end

  def generate_markdown(input) do
    Cmark.to_html(input, [:safe, :hardbreaks])
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
    |> Enum.map(&get_or_insert_tag(&1, site_id))
  end

  def get_or_insert_tag(name, site_id) do
    inserted_tag =
      Repo.insert(
        %Tag{name: name, site_id: site_id, color: "686868"},
        on_conflict: :nothing
      )

    case inserted_tag do
      %{id: id} when id != nil ->
        inserted_tag

      _ ->
        Repo.get_by!(Tag, name: name, site_id: site_id)
    end
  end

  defp parse_date(%{"date" => date, "hour" => hour} = attrs) do
    [h, m, s] =
      hour
      |> Enum.map(fn {_, v} -> if String.length(v) == 1, do: "0" <> v, else: v end)

    iso_hour = %{hour: h, minute: m, second: s}
    date_string = "#{date} #{iso_hour.hour}:#{iso_hour.minute}:#{iso_hour.second}"
    {:ok, datetime} = NaiveDateTime.from_iso8601(date_string)

    Map.put(attrs, "inserted_at", datetime)
  end

  defp parse_date(attrs) do
    now = NaiveDateTime.utc_now |> NaiveDateTime.truncate(:second)
    Map.put(attrs, "inserted_at", now)
  end

  def generate_og_meta(conn, %Post{title: title, thumbnail: _image, abstract: description} = post) do
    type = "article"
    title = "#{title} - #{conn.assigns.site.name}"
    url = PostView.show_link(conn, post)
    image = PostView.show_thumb_link(conn, post)
    %{url: url, type: type, title: title, description: description, image: image}
  end

  def increase_views_for_popular_by_1(%Post{id: post_id, site_id: site_id} = post) do
    Redix.command(:redix, ["ZINCRBY", "site:#{site_id}", 1, post_id])
    post
  end
end
