defmodule ElephantInTheRoomWeb.Faker.Site do
  alias ElephantInTheRoom.Sites

  defp default_attrs do
    name =
      Faker.Commerce.product_name()
      |> String.split()
      |> Enum.take_random(Faker.random_between(1,2))
      |> Enum.join(" ")

    %{
      name: name,
      host: "localhost"
    }
  end

  def insert_one(attrs \\ %{}) do
    changes = Map.merge(default_attrs(), attrs)

    case Sites.create_site(changes) do
      {:ok, site} ->
        site
      {:error, _} ->
        insert_one(attrs)
    end
  end

  def insert_many(n, attrs \\ %{}) do
    Enum.to_list(1..n)
    |> Enum.map(fn _ -> insert_one(attrs) end)
  end
end
