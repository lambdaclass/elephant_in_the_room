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
  end
end
