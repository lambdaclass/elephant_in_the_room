defmodule ElephantInTheRoom.Sites.Tag do
  use Ecto.Schema
  import Ecto.Changeset
  alias ElephantInTheRoom.Sites.{Site, Tag, Post}

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
    attrs = remove_numeral_from_color(attrs)

    tag
    |> cast(attrs, [:name, :color, :site_id])
    |> validate_required([:name, :color, :site_id])
    |> unique_constraint(:name)
  end

  defp remove_numeral_from_color(%{"color" => color} = attrs), do:
    %{attrs | "color" => String.replace(color, "#", "")}
  defp remove_numeral_from_color(attrs), do: attrs

end
