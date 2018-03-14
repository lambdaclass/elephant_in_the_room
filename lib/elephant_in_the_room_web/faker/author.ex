defmodule ElephantInTheRoomWeb.Faker.Author do
  alias ElephantInTheRoom.Sites

  def default_attrs do
    %{
      description: Faker.Lorem.paragraph(2),
      image: Faker.Avatar.image_url(),
      name: Faker.Name.name()
    }
  end

  def insert_one(attrs \\ %{}) do
    changes = Map.merge(default_attrs, attrs)

    Sites.create_author(changes)
  end

  def insert_many(attrs \\ %{}, n) do
    Enum.to_list(1..n)
    |> Enum.each(fn _ -> insert_one(attrs) end)
  end
end
