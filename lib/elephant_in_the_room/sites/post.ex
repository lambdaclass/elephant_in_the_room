defmodule ElephantInTheRoom.Sites.Post do
  use Ecto.Schema
  import Ecto.Changeset
  alias ElephantInTheRoom.Sites.{Post, Site, Category, Tag}
  alias ElephantInTheRoom.Repo

  schema "posts" do
    field(:content, :string)
    field(:image, :string)
    field(:title, :string)

    belongs_to(:site, Site, foreign_key: :site_id)

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
    attrs
    |> inspect()
    |> IO.puts()

    post
    |> cast(attrs, [:title, :content, :image, :site_id])
    |> put_assoc(:tags, parse_tags(attrs))
    |> put_assoc(:categories, parse_categories(attrs))
    |> validate_required([:title, :content, :image, :site_id])
    |> unique_constraint(:title)
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
