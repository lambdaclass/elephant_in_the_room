defmodule ElephantInTheRoom.Sites.Author do
  use Ecto.Schema
  import Ecto.Changeset
  alias ElephantInTheRoom.Sites.{Author, Post}

  schema "authors" do
    field(:description, :string)
    field(:image, :string)
    field(:name, :string)

    has_many(:posts, Post, on_delete: :nilify_all)

    timestamps()
  end

  @doc false
  def changeset(%Author{} = author, attrs) do
    author
    |> cast(attrs, [:name, :image, :description])
    |> validate_required([:name, :image, :description])
    |> unique_constraint(:name)
  end
end
