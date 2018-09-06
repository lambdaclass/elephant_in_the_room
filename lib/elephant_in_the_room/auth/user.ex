defmodule ElephantInTheRoom.Auth.User do
  use ElephantInTheRoom.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false
  alias Comeonin.Bcrypt
  alias ElephantInTheRoom.Auth.{Role, User}
  alias ElephantInTheRoom.Repo

  schema "users" do
    field(:email, :string)
    field(:firstname, :string)
    field(:lastname, :string)
    field(:password, :string)
    field(:username, :string)

    belongs_to(:role, Role)
    timestamps()
  end

  @doc false
  def changeset(%User{} = user, attrs \\ %{}) do
    user
    |> cast(attrs, [:username, :firstname, :lastname, :email, :password, :role_id])
    |> validate_required([:username, :firstname, :lastname, :email, :password, :role_id], message: "Campo requerido.")
    |> unique_constraint(:username, message: "Ya existe.")
    |> unique_constraint(:email, message: "Ya existe.")
    |> validate_format(:email, ~r/.+@.+\..+/i, message: "E-mail con formato incorrecto.")
    |> validate_length(:password, min: 6, message: "Minimo 6 caracteres")
    |> validate_length(:username, min: 4, message: "Minimo 4 caracteres")
    |> put_pass_hash()
  end

  defp put_pass_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    changeset |> change(password: Bcrypt.hashpwsalt(password))
  end

  defp put_pass_hash(changeset) do
    changeset
  end

  def get_first_user do
    user = from user in User,
      limit: 1,
      order_by: [asc: user.inserted_at]
    Repo.one!(user)
  end

  def delete_user(%User{id: user_id} = user) do
    %User{id: first_user_id} = get_first_user()
    if first_user_id == user_id do
      changeset(user)
      |> add_error(:fist_user, "can't delete first user")
    else
      Repo.delete(user)
    end
  end

end
