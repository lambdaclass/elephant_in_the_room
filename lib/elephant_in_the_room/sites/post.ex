defmodule ElephantInTheRoom.Sites.Post do
  use Ecto.Schema
  import Ecto.Changeset
  alias ElephantInTheRoom.Sites.{Post, Category}

  schema "posts" do
    field(:title, :string)
    field(:content, :string)
    field(:image, :string)
    field(:tag, {:array, :string})

    belongs_to(:category, Category, foreign_key: :category_id)

    timestamps()
  end

  @doc false
  def changeset(%Post{} = post, attrs) do
    post
    |> cast(attrs, [:title, :image, :content, :category_id])
    |> validate_required([:title, :image, :content, :category_id])
    |> assoc_constraint(:category)
  end
end
