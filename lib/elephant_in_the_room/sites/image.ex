defmodule ElephantInTheRoom.Sites.Image do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
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
