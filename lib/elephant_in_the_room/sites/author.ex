defmodule ElephantInTheRoom.Sites.Author do
  use ElephantInTheRoom.Schema
  use Arc.Ecto.Schema
  import Ecto.Changeset
  alias ElephantInTheRoom.Posts.Post
  alias ElephantInTheRoom.Repo
  alias ElephantInTheRoom.Sites.Author
  alias ElephantInTheRoomWeb.Uploaders.Image

  schema "authors" do
    field(:description, :string)
    field(:image, Image.Type)
    field(:name, :string)
    field(:is_columnist, :boolean, default: false)

    has_many(:posts, Post, on_delete: :nilify_all)

    timestamps()
  end

  @doc false
  def changeset(%Author{} = author, attrs) do
    author
    |> cast(attrs, [:name, :description, :is_columnist])
    |> cast_attachments(attrs, [:image], [])
    |> validate_required([:name, :is_columnist])
    |> unique_constraint(:name)
  end

  def ensure_author_exists(author_id) when is_binary(author_id) do
    with dumped_id when dumped_id != :error <- Ecto.UUID.dump(author_id),
         %Author{} = author <- Repo.get_by(Author, id: author_id) do
      author
    else
      _ ->
        %Author{name: author_id}
        |> Author.changeset(%{})
        |> Repo.insert()
    end
  end

  def ensure_author_exists(_), do: {:error, :invalid_id}
end
