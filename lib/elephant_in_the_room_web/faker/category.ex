defmodule ElephantInTheRoomWeb.Faker.Category do
  alias ElephantInTheRoom.Posts

  defp default_attrs do
    %{
      "name" => Faker.Industry.sub_sector(),
      "description" => Faker.Lorem.sentence(10)
    }
  end

  def insert_one(attrs \\ %{}) do
    changes = Map.merge(default_attrs(), attrs)

    case Posts.create_category(attrs["site"], changes) do
      {:ok, category} ->
        category
      {:error, _} ->
        insert_one(attrs)
    end
  end

  def insert_many(n, attrs \\ %{}) do
    Enum.to_list(1..n)
    |> Enum.map(fn _ -> insert_one(attrs) end)
  end
end
