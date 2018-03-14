defmodule ElephantInTheRoomWeb.Faker.Category do
  alias ElephantInTheRoom.Sites

  # site 1 
  def default_attrs do
    %{
      name: Faker.Company.bullshit(),
      description: Faker.Lorem.sentence(10)
    }
  end

  def insert_one(attrs \\ %{}) do
    changes = Map.merge(default_attrs, attrs)

    Sites.create_category(attrs[:site], attrs)
  end

  def insert_many(attrs \\ %{}, n) do
    Enum.to_list(1..n)
    |> Enum.each(fn _ -> insert_one(attrs) end)
  end
end
