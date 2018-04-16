defmodule ElephantInTheRoom.Sites.Site do
  use Ecto.Schema
  import Ecto.Changeset
  alias ElephantInTheRoom.Sites.{Site, Category, Post, Tag}
  alias ElephantInTheRoom.Sites

  schema "sites" do
    field(:name, :string)
    field(:url, :string)

    has_many(:categories, Category, on_delete: :delete_all)
    has_many(:posts, Post, on_delete: :delete_all)
    has_many(:tags, Tag, on_delete: :delete_all)

    timestamps()
  end

  @doc false
  def changeset(%Site{} = site, attrs) do
    site
    |> cast(attrs, [:name, :url])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
