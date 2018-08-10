defmodule ElephantInTheRoomWeb.Faker.Site do
  alias ElephantInTheRoom.Sites

  defp default_attrs do
    name =
      Faker.Commerce.product_name()
      |> String.split()
      |> Enum.take_random(Faker.random_between(1, 2))
      |> Enum.join(" ")

    %{
      "name" => name,
      "ads_title" => "Promociones"
    }
  end

  def insert_one(site_number, attrs \\ %{}) do
    host = if site_number == 0, do: "localhost", else: "site-#{site_number}.com"

    changes =
      default_attrs()
      |> Map.merge(attrs)
      |> Map.put("host", host)

    case Sites.create_site(changes) do
      {:ok, site} ->
        site

      {:error, _reason} ->
        insert_one(site_number + 1, attrs)
    end
  end

  def insert_many(n, attrs \\ %{}) do
    Enum.to_list(0..n)
    |> Enum.map(fn n -> insert_one(n, attrs) end)
  end
end
