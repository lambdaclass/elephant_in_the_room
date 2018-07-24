defmodule ElephantInTheRoom.Sites.Site do
  use Ecto.Schema
  import Ecto.Changeset
  alias ElephantInTheRoom.Sites.{Site, Category, Post, Tag, Author}

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "sites" do
    field(:name, :string)
    field(:host, :string)

    has_many(:categories, Category, on_delete: :delete_all)
    has_many(:posts, Post, on_delete: :delete_all)
    has_many(:tags, Tag, on_delete: :delete_all)
    many_to_many(:authors, Author, join_through: Post)

    timestamps()
  end

  @doc false
  def changeset(%Site{} = site, attrs) do
    site
    |> cast(attrs, [:name, :host])
    |> validate_required([:name, :host])
    |> unique_constraint(:name)
    |> unique_constraint(:host)
  end
end
