defmodule ElephantInTheRoom.Sites.Magazine do
  use ElephantInTheRoom.Schema
  import Ecto.Changeset
  alias ElephantInTheRoom.Posts.Post
  alias ElephantInTheRoom.Sites.Site
  alias ElephantInTheRoomWeb.Uploaders.Image

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
    |> cast(attrs, [:title, :description, :site_id])
    |> validate_required([:title, :description, :site_id])
    |> assoc_constraint(:site)
    |> unique_constraint(:title, name: :title_unique_index)
    |> validate_cover(attrs)
  end

  defp validate_cover(%{valid?: false} = changeset, _attrs) do
    changeset
  end

  defp validate_cover(changeset, %{"cover" => cover}) do
    {:ok, cover_name} = Image.store(%{cover | filename: Ecto.UUID.generate()})

    put_change(changeset, :cover, cover_name)
  end

  defp validate_cover(changeset, _attrs) do
    case get_field(changeset, :cover) do
      nil ->
        add_error(changeset, :cover, "can't be blank")
      _ ->
        changeset
    end
  end
end
