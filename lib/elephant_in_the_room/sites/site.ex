defmodule ElephantInTheRoom.Sites.Site do
  use Ecto.Schema
  import Ecto.Changeset
  alias ElephantInTheRoom.Sites.{Site, Category, Post, Tag}

  schema "sites" do
    field(:name, :string)

    has_many(:categories, Category)
    has_many(:posts, Post)
    has_many(:tags, Tag)

    timestamps()
  end

  @doc false
  def changeset(%Site{} = site, attrs) do
    site
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
