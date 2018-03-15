defmodule ElephantInTheRoom.Repo.Faker.User do
  alias ElephantInTheRoom.Auth

  defp default_attrs do
    first_name = Faker.Name.first_name()
    last_name = Faker.Name.last_name()
    user_name = first_name <> last_name <> to_string(:rand.uniform(100))

    %{
      first_name: first_name,
      last_name: last_name,
      username: user_name,
      email: Faker.Internet.email(),
      password: "secretsecret"
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
