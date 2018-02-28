defmodule ElephantInTheRoom.Post do
  use Ecto.Schema
  import Ecto.Changeset
  alias ElephantInTheRoom.Post

  schema "posts" do
    field :title, :string
    field :content, :string

    timestamps()
  end

  @doc false
  def changeset(%Post{} = post \\ %Post{}, attrs \\ %{}) do
    post
    |> cast(attrs, [:title, :content])
    |> validate_required([:title, :content])
    |> validate_length(:title, min: 4, message: "Title is too short")
    |> validate_length(:content, min: 4, message: "Content is too short")
  end
end
