defmodule ElephantInTheRoom.Posts.Tag do
  use ElephantInTheRoom.Schema
  import Ecto.Changeset
  alias ElephantInTheRoom.Posts.{Post, Tag}
  alias ElephantInTheRoom.Sites.Site

  schema "tags" do
    field(:name, :string)
    field(:color, :string)

    belongs_to(:site, Site, foreign_key: :site_id)

    many_to_many(
      :posts,
      Post,
      join_through: "posts_tags",
      on_replace: :delete,
      on_delete: :delete_all
    )

    timestamps()
  end

  @doc false
  def changeset(%Tag{} = tag, attrs) do
    tag
    |> cast(attrs, [:name, :color, :site_id])
    |> ensure_color(tag, attrs)
    |> validate_required([:name, :color, :site_id])
    |> unique_constraint(:name)
  end

  defp ensure_color(changeset, tag, attrs) do
    color =
      case attrs do
        %{"color" => color} ->
          remove_numeral_from_color(color)
        _ ->
          case tag do
            %{color: color} when is_binary(color) -> color
            _ ->  get_random_predefined_color()
          end
      end
    put_change(changeset, :color, color)
  end

  defp remove_numeral_from_color(color), do:
    String.replace(color, "#", "")

  def predefined_colors do
    ["e4830b",
     "6cbd01",
     "1e87f0",
     "32d296",
     "f0506e",
     "d231dc"]
  end

  def get_random_predefined_color do
    colors = predefined_colors()
    pos = :rand.uniform(length(colors)) - 1
    Enum.at(colors, pos)
  end

end
