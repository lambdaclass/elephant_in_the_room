defmodule ElephantInTheRoom.Sites.Comment do
  use Ecto.Schema
  import Ecto.Changeset
  alias ElephantInTheRoom.Sites.Comment


  schema "comments" do
    field :text, :string

    belongs_to :post, Post, foreign_key: :user_id

    timestamps()
  end

  @doc false
  def changeset(%Comment{} = comment, attrs) do
    comment
    |> cast(attrs, [:text])
    |> validate_required([:text])
  end
end
