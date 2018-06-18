defmodule ElephantInTheRoomWeb.Faker.Author do
  alias ElephantInTheRoom.Sites
  alias ElephantInTheRoomWeb.Faker.Utils

  defp default_attrs do
    %{
      "description" => Faker.Lorem.paragraph(2),
      "image" => Faker.Avatar.image_url(),
      "name" => Faker.Name.name()
    }
  end

  def insert_one(attrs \\ %{}) do
    changes = Map.merge(default_attrs(), attrs)
    new_changes = Utils.fake_image_upload(changes, "jpg")
    {:ok, author} = Sites.create_author(new_changes)
    author
  end

  def insert_many(n, attrs \\ %{}) do
    Enum.to_list(1..n)
    |> Enum.map(fn _ -> insert_one(attrs) end)
  end
end
