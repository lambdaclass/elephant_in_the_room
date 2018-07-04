defmodule ElephantInTheRoomWeb.Faker.Category do
  alias ElephantInTheRoom.Sites

  # site 1 
  defp default_attrs do
    %{
      "name" => Faker.Company.bullshit() <> to_string(:rand.uniform(10000)),
      "description" => Faker.Lorem.sentence(10)
    }
  end

  def insert_one(attrs \\ %{}) do
    changes = Map.merge(default_attrs(), attrs)

    {:ok, category} = Sites.create_category(attrs["site"], changes)
    category
  end

  def insert_many(n, attrs \\ %{}) do
    Enum.to_list(1..n)
    |> Enum.map(fn _ -> insert_one(attrs) end)
  end
end
