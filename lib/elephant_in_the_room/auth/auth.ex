defmodule ElephantInTheRoom.Auth do
  @moduledoc """
  The Auth context.
  """

  import Ecto.Query, warn: false
  alias Comeonin.Bcrypt
  alias ElephantInTheRoom.Auth.{Guardian, Role, User}
  alias ElephantInTheRoom.Repo
  alias Plug.Conn

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    User
    |> Repo.all()
    |> Repo.preload(:role)
  end

  def get_user!(id) do
    User
    |> Repo.get!(id)
    |> Repo.preload(:role)
  end

  def get_user(%Conn{} = conn) do
    case Guardian.Plug.current_resource(conn) do
      nil ->
        {:error, :no_user}

      %User{} = user ->
        user = Repo.preload(user, :role)
        {:ok, user}
    end
  end

  def get_user(id) do
    case Repo.get(User, id) do
      nil ->
        {:error, :user_not_found}

      user ->
        user = Repo.preload(user, :role)
        {:ok, user}
    end
  end

  def sign_in_user(%Conn{} = conn, %User{} = user) do
    conn = Guardian.Plug.sign_in(conn, user)
    user = Repo.preload(user, :role)
    {:ok, conn, user}
  end

  def sign_out_user(%Conn{} = conn) do
    Guardian.Plug.sign_out(conn)
  end

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def create_user!(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert!()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a User.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    User.delete_user(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  @doc """
  Returns the list of roles.

  ## Examples

      iex> list_roles()
      [%Role{}, ...]

  """
  def list_roles do
    Repo.all(Role)
  end

  @doc """
  Gets a single role.

  Raises `Ecto.NoResultsError` if the Role does not exist.

  ## Examples

      iex> get_role!(123)
      %Role{}

      iex> get_role!(456)
      ** (Ecto.NoResultsError)

  """
  def get_role!(id) do
    Repo.get!(Role, id)
  end

  @doc """
  Creates a role.

  ## Examples

      iex> create_role(%{field: value})
      {:ok, %Role{}}

      iex> create_role(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_role(attrs \\ %{}) do
    %Role{}
    |> Role.changeset(attrs)
    |> Repo.insert()
  end

  def create_role!(attrs \\ %{}) do
    %Role{}
    |> Role.changeset(attrs)
    |> Repo.insert!()
  end

  @doc """
  Updates a role.

  ## Examples

      iex> update_role(role, %{field: new_value})
      {:ok, %Role{}}

      iex> update_role(role, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_role(%Role{} = role, attrs) do
    role
    |> Role.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Role.

  ## Examples

      iex> delete_role(role)
      {:ok, %Role{}}

      iex> delete_role(role)
      {:error, %Ecto.Changeset{}}

  """
  def delete_role(%Role{} = role) do
    Repo.delete(role)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking role changes.

  ## Examples

      iex> change_role(role)
      %Ecto.Changeset{source: %Role{}}

  """
  def change_role(%Role{} = role) do
    Role.changeset(role, %{})
  end

  def authenticate_user(username, plain_text_password) do
    query = from(u in User, where: u.username == ^username)

    Repo.one(query)
    |> check_password(plain_text_password)
  end

  defp check_password(nil, _) do
    {:error, "Incorrect username or password"}
  end

  defp check_password(user, plain_text_password) do
    case Bcrypt.checkpw(plain_text_password, user.password) do
      true -> {:ok, user}
      false -> {:error, "Incorrect username or password"}
    end
  end

  def get_by_name!(name, model) do
    Repo.get_by!(model, name: name)
  end

  def get_by_name(name, model) do
    Repo.get_by(model, name: name)
  end

  def from_name!(name, model) do
    name
    |> URI.decode()
    |> get_by_name!(model)
  end

  def from_username!(username) do
    name = URI.decode(username)

    User
    |> Repo.get_by!(username: name)
    |> Repo.preload([:role])
  end
end
