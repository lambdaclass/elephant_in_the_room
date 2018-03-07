defmodule ElephantInTheRoom.Auth.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias ElephantInTheRoom.Auth.{User, Role}
  alias Comeonin.Bcrypt

  schema "users" do
    field(:email, :string)
    field(:firstname, :string)
    field(:lastname, :string)
    field(:password, :string)
    field(:username, :string)

    has_many(:comments, Comment, on_delete: :delete_all)

    belongs_to(:role, Role)
    timestamps()
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:username, :firstname, :lastname, :email, :password, :role_id])
    |> validate_required([:username, :firstname, :lastname, :email, :password, :role_id])
    |> unique_constraint(:username)
    |> unique_constraint(:email)
    |> validate_format(:email, ~r/@/)
    |> validate_length(:password, min: 6)
    |> validate_length(:username, min: 4)
    |> put_pass_hash()
  end

  defp put_pass_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    changeset |> change(password: Bcrypt.hashpwsalt(password))
  end

  defp put_pass_hash(changeset) do
    changeset
  end
end
