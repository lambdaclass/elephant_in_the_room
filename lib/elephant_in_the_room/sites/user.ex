defmodule ElephantInTheRoom.Sites.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias ElephantInTheRoom.Sites.User


  schema "users" do
    field :email, :string
    field :firstname, :string
    field :lastname, :string
    field :password, :string
    field :username, :string

    timestamps()
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:username, :firstname, :lastname, :email, :password])
    |> validate_required([:username, :firstname, :lastname, :email, :password])
    |> unique_constraint(:username)
    |> unique_constraint(:email)
  end
end
