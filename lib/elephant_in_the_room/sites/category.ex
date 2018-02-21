defmodule ElephantInTheRoom.Sites.Category do
  use Ecto.Schema
  import Ecto.Changeset
  alias ElephantInTheRoom.Sites.{Category, Site, Post}

  schema "categories" do
    field(:name, :string)
    field(:description, :string)

    belongs_to(:site, Site, foreign_key: :site_id)

    has_many(:posts, Post)

    timestamps()
  end

  @doc false
  def changeset(%Category{} = category, attrs) do
    category
    |> cast(attrs, [:name, :description, :site_id])
    |> validate_required([:name, :description, :site_id])
    |> assoc_constraint(:site)
  end
end
