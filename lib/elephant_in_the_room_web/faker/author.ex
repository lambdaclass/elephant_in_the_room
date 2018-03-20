defmodule ElephantInTheRoomWeb.Faker.Author do
  alias ElephantInTheRoom.Sites

  defp default_attrs do
    %{
      "description" => Faker.Lorem.paragraph(2),
      "image" => Faker.Avatar.image_url(),
      "name" => Faker.Name.name()
    }
  end

  def insert_one(attrs \\ %{}) do
    changes = Map.merge(default_attrs(), attrs)

    {:ok, author} = Sites.create_author(changes)
    author
  end

  def insert_many(n, attrs \\ %{}) do
    Enum.to_list(1..n)
    |> Enum.map(fn _ -> insert_one(attrs) end)
  end
end
