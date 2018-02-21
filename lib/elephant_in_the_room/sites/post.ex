defmodule ElephantInTheRoom.Sites.Post do
  use Ecto.Schema
  import Ecto.Changeset
  alias ElephantInTheRoom.Sites.{Post, Category}

  schema "posts" do
    field(:title, :string)
    field(:content, :string)
    field(:image, :string)
    field(:tag, {:array, :string})

    belongs_to(:category, Category)

    timestamps()
  end

  @doc false
  def changeset(%Post{} = post, attrs) do
    post
    |> cast(attrs, [:name, :image, :content, :category_id, :site_id])
    |> validate_required([:name, :image, :content, :category_id])
    |> assoc_constraint(:category)
    |> assoc_constraint(:site)
  end
end
