defmodule ElephantInTheRoomWeb.Faker.User do
  alias ElephantInTheRoom.Auth
  alias ElephantInTheRoom.Repo

  defp choose_role() do
    admin_role = Repo.get_by!(Auth.Role, name: "admin")
    user_role = Repo.get_by!(Auth.Role, name: "user")

    case :rand.uniform(2) do
      1 -> admin_role
      2 -> user_role
    end
  end

  def default_attrs do
    first_name = Faker.Name.first_name()
    last_name = Faker.Name.last_name()
    user_name = first_name <> last_name <> to_string(:rand.uniform(100))
    role = choose_role()

    %{
      firstname: first_name,
      lastname: last_name,
      username: user_name,
      email: Faker.Internet.email(),
      password: "secretsecret",
      role_id: role.id
    }
  end

  def insert_one(attrs \\ %{}) do
    changes = Map.merge(default_attrs(), attrs)

    {:ok, user} = Auth.create_user(changes)
    user
  end

  def insert_many(n, attrs \\ %{}) do
    Enum.to_list(1..n)
    |> Enum.map(fn _ -> insert_one(attrs) end)
  end
end
