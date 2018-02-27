defmodule ElephantInTheRoom.Sites.Post do
  use Ecto.Schema
  import Ecto.Changeset
  alias ElephantInTheRoom.Sites.{Post, Site, Category, Tag}
  alias ElephantInTheRoom.{Sites, Repo}

  schema "posts" do
    field(:content, :string)
    field(:image, :string)
    field(:title, :string)

    belongs_to(:site, Site, foreign_key: :site_id)

    many_to_many(:categories, Category, join_through: "posts_categories")
    many_to_many(:tags, Tag, join_through: "posts_tags")

    timestamps()
  end

  def get_selected_tags_id(attrs) do
    site_id = Map.get(attrs, "site_id")

    Map.get(attrs, "selected_tags", %{})
    |> Enum.map(&Sites.get_tag_by_name!(site_id, &1))
    |> Enum.map(& &1.id)
  end

  def load_tags(attrs) do
    if Map.has_key?(attrs, "site_id") do
      selected_tags =
        attrs
        |> get_selected_tags_id()

      Map.put(attrs, "tags", selected_tags)
    else
      attrs
    end
  end

  @doc false
  def changeset(%Post{} = post, attrs) do
    attrs_with_tags = load_tags(attrs)

    post
    |> cast(attrs_with_tags, [:title, :content, :image, :site_id])
    |> cast_assoc(:tags)
    |> validate_required([:title, :content, :image, :site_id])
    |> unique_constraint(:title)
  end
end
