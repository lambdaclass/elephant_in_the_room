defmodule ElephantInTheRoom.Sites.Post do
  use Ecto.Schema
  import Ecto.Changeset
  alias ElephantInTheRoom.Sites.{Post, Category}

  schema "posts" do
    field(:title, :string)
    field(:content, :string)
    field(:image, :string)
    field(:tag, :string)

    belongs_to(:category, Category)

    timestamps()
  end

  @doc false
  def changeset(%Post{} = post, attrs) do
    post
    |> cast(attrs, [:name, :image, :content])
    |> validate_required([:name, :image, :content])
    |> assoc_constraint(:category)
  end
end
