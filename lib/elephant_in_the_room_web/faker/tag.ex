defmodule ElephantInTheRoomWeb.Faker.Tag do
  alias ElephantInTheRoom.Sites

  def default_attrs do
    %{
      name: Faker.Pizza.cheese()
    }
  end

  def insert_one(attrs \\ %{}) do
    changes = Map.merge(default_attrs, attrs)

    Sites.create_tag(attrs[:site], changes)
  end

  def insert_many(attrs \\ %{}, n) do
    Enum.to_list(1..n)
    |> Enum.each(fn _ -> insert_one(attrs) end)
  end
end
