defmodule ElephantInTheRoom.AuthTest do
  use ElephantInTheRoom.DataCase
  alias ElephantInTheRoom.Repo
  alias ElephantInTheRoom.Auth
  alias ElephantInTheRoom.Auth.{User, Role}
  alias Comeonin.Bcrypt

  describe "roles" do
    @valid_attrs %{"name" => "some name"}
    @update_attrs %{"name" => "some updated name"}
    @invalid_attrs %{"name" => nil}

    def role_fixture(attrs \\ %{}) do
      {:ok, role} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Auth.create_role()

      role
    end

    test "list_roles/0 returns all roles" do
      role = role_fixture()
      assert Auth.list_roles() == [role]
    end

    test "get_role!/1 returns the role with given id" do
      role = role_fixture()
      assert Auth.get_role!(role.id) == role
    end

    test "create_role/1 with valid data creates a role" do
      assert {:ok, %Role{} = role} = Auth.create_role(@valid_attrs)
      assert role.name == "some name"
    end

    test "create_role/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Auth.create_role(@invalid_attrs)
    end

    test "update_role/2 with valid data updates the role" do
      role = role_fixture()
      assert {:ok, role} = Auth.update_role(role, @update_attrs)
      assert %Role{} = role
      assert role.name == "some updated name"
    end

    test "update_role/2 with invalid data returns error changeset" do
      role = role_fixture()
      assert {:error, %Ecto.Changeset{}} = Auth.update_role(role, @invalid_attrs)
      assert role == Auth.get_role!(role.id)
    end

    test "delete_role/1 deletes the role" do
      role = role_fixture()
      assert {:ok, %Role{}} = Auth.delete_role(role)
      assert_raise Ecto.NoResultsError, fn -> Auth.get_role!(role.id) end
    end

    test "change_role/1 returns a role changeset" do
      role = role_fixture()
      assert %Ecto.Changeset{} = Auth.change_role(role)
    end
  end

  describe "users" do
    @valid_attrs %{
      "email" => "some@email.com",
      "firstname" => "some firstname",
      "lastname" => "some lastname",
      "password" => "some_password",
      "username" => "some_username"
    }
    @update_attrs %{
      "email" => "some_updated@email.com",
      "firstname" => "some updated firstname",
      "lastname" => "some updated lastname",
      "password" => "some_updated_password",
      "username" => "updated_username"
    }
    @invalid_attrs %{
      "email" => "not an email",
      "firstname" => "some name",
      "lastname" => "some lastname",
      "password" => "n",
      "username" => "0"
    }

    def user_fixture(attrs \\ %{}) do
      role = role_fixture(%{"name" => "some role name"})

      new_attrs =
        attrs
        |> Enum.into(@valid_attrs)
        |> Enum.into(%{"role_id" => role.id})

      {:ok, user} = Auth.create_user(new_attrs)

      user |> Repo.preload(:role)
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Auth.list_users() == [Repo.preload(user, :role)]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Auth.get_user!(user.id) == Repo.preload(user, :role)
    end

    test "create_user/1 with valid data creates a user" do
      role = role_fixture()
      valid_attrs = Enum.into(@valid_attrs, %{"role_id" => role.id})

      assert {:ok, %User{} = user} = Auth.create_user(valid_attrs)
      assert user.email == "some@email.com"
      assert user.firstname == "some firstname"
      assert user.lastname == "some lastname"
      assert Bcrypt.checkpw("some_password", user.password)
      assert user.username == "some_username"
      assert user.role_id == role.id
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Auth.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      role = role_fixture()
      user = user_fixture()
      updated_attrs = Enum.into(@update_attrs, %{"role_id" => role.id})
      assert {:ok, user} = Auth.update_user(user, updated_attrs)
      assert %User{} = user
      assert user.email == "some_updated@email.com"
      assert user.firstname == "some updated firstname"
      assert user.lastname == "some updated lastname"
      assert Bcrypt.checkpw("some_updated_password", user.password)
      assert user.username == "updated_username"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Auth.update_user(user, @invalid_attrs)
      assert user == Auth.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Auth.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Auth.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Auth.change_user(user)
    end
  end
end
