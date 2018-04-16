defmodule ElephantInTheRoom.Sites.Author do
  use Ecto.Schema
  import Ecto.Changeset
  alias ElephantInTheRoom.Sites.{Author, Post}
  alias ElephantInTheRoomWeb.Uploaders.Image
  import Arc.Ecto.Model

  schema "authors" do
    field(:description, :string)
    field(:image, Image.Type)
    field(:name, :string)

    has_many(:posts, Post, on_delete: :nilify_all)

    timestamps()
  end

  @doc false
  def changeset(%Author{} = author, attrs) do
    author
    |> cast(attrs, [:name, :description])
    |> cast(attrs, [:image])
    |> validate_required([:name, :description])
    |> unique_constraint(:name)
  end
end
