defmodule ElephantInTheRoom.Sites.Comment do
  use Ecto.Schema
  import Ecto.Changeset
  alias ElephantInTheRoom.Sites.Comment


  schema "comments" do
    field :text, :string

    timestamps()
  end

  @doc false
  def changeset(%Comment{} = comment, attrs) do
    comment
    |> cast(attrs, [:text])
    |> validate_required([:text])
  end
end
