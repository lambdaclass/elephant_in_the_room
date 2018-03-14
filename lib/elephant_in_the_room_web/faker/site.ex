defmodule ElephantInTheRoomWeb.Faker.Site do
  alias ElephantInTheRoom.Sites

  def default_attrs do
    %{
      name: Faker.Pokemon.name()
    }
  end

  def insert_one(site, attrs \\ %{}) do
    changes = Map.merge(default_attrs, attrs)

    Sites.create_site(changes)
  end

  def insert_many(site, attrs \\ %{}, n) do
    Enum.to_list(1..n)
    |> Enum.each(fn _ -> insert_one(site, attrs) end)
  end
end
