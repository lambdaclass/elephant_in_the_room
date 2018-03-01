defmodule ElephantInTheRoom.Sites.Tag do
  use Ecto.Schema
  import Ecto.Changeset
  alias ElephantInTheRoom.Sites.{Site, Tag, Post}

  schema "tags" do
    field(:name, :string)

    belongs_to(:site, Site, foreign_key: :site_id)

    many_to_many(:posts, Post, join_through: "posts_tags", on_delete: :delete_all)

    timestamps()
  end

  @doc false
  def changeset(%Tag{} = tag, attrs) do
    tag
    |> cast(attrs, [:name, :site_id])
    |> validate_required([:name, :site_id])
    |> unique_constraint(:name)
  end
end
