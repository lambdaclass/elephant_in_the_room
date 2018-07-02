defmodule ElephantInTheRoom.Sites.Image do
  use Ecto.Schema
  import Ecto.Changeset

  schema "images" do
    field(:binary, :binary)
    field(:type, :string)

    timestamps()
  end

  @doc false
  def changeset(image, attrs) do
    image
    |> cast(attrs, [:binary, :type])
    |> validate_required([:binary, :type])
  end
end
