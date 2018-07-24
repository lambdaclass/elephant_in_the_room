defmodule ElephantInTheRoom.Auth.Role do
  use Ecto.Schema
  import Ecto.Changeset
  alias ElephantInTheRoom.Auth.{Role, User}

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "roles" do
    field(:name, :string)
    has_many(:users, User)
    timestamps()
  end

  @doc false
  def changeset(%Role{} = role, attrs) do
    role
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
