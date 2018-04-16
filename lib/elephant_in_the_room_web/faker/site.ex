defmodule ElephantInTheRoomWeb.Faker.Site do
  alias ElephantInTheRoom.Sites

  defp default_attrs do
    site_number = to_string(:rand.uniform(100_000_000))

    %{
      "name" => "Site " <> site_number,
      "url" => "site-" <> site_number <> ".com"
    }
  end

  def insert_one(attrs \\ %{}) do
    changes = Map.merge(default_attrs(), attrs)

    {:ok, site} = Sites.create_site(changes)
    site
  end

  def insert_many(n, attrs \\ %{}) do
    Enum.to_list(1..n)
    |> Enum.map(fn _ -> insert_one(attrs) end)
  end
end
