defmodule ElephantInTheRoom.Sites.Image do
  use Ecto.Schema
  import Ecto.Changeset

  schema "images" do
    field(:name, :string)
    field(:binary, :binary)
    field(:type, :string)

    timestamps()
  end

  @doc false
  def changeset(image, attrs) do
    image
    |> cast(attrs, [:name, :binary, :type])
    |> validate_required([:name, :binary, :type])
  end
end
