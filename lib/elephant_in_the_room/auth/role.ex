defmodule ElephantInTheRoom.Auth.Role do
  use ElephantInTheRoom.Schema
  import Ecto.Changeset
  alias ElephantInTheRoom.Auth.{Role, User}

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
