defmodule ElephantInTheRoom.Sites.Image do
  use ElephantInTheRoom.Schema
  import Ecto.Changeset

  schema "images" do
    field(:name, :string)
    field(:binary, :binary)

    timestamps()
  end

  @doc false
  def changeset(image, attrs) do
    image
    |> cast(attrs, [:name, :binary])
    |> validate_required([:name, :binary])
  end
end
