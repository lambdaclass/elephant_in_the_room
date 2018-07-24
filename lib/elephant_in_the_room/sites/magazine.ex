defmodule ElephantInTheRoom.Sites.Magazine do
  use Ecto.Schema
  import Ecto.Changeset
  alias ElephantInTheRoom.Sites.{Site, Post}


  schema "magazines" do
    field :cover, :string
    field :description, :string
    field :title, :string

    belongs_to :site, Site
    has_many :posts, Post

    timestamps()
  end

  @doc false
  def changeset(magazine, attrs) do
    magazine
    |> cast(attrs, [:title, :cover, :description, :site_id])
    |> validate_required([:title, :cover, :description, :site_id])
  end
end
