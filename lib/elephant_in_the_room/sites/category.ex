defmodule ElephantInTheRoom.Sites.Category do
  use Ecto.Schema
  import Ecto.Changeset
  alias ElephantInTheRoom.Sites.{Category, Site, Post}

  schema "categories" do
    field(:description, :string)
    field(:name, :string)

    belongs_to(:site, Site)

    has_many(:posts, Post)

    timestamps()
  end

  @doc false
  def changeset(%Category{} = category, attrs) do
    category
    |> cast(attrs, [:name, :description])
    |> validate_required([:name, :description])
    |> assoc_constraint(:site)
  end
end
