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

  def insert_one(arg, attrs \\ %{})

  def insert_one(site_number, attrs)
      when is_integer(site_number) do
    host = generate_local_name(site_number)

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

  def insert_one(host, attrs) when is_binary(host) do
    changes =
      default_attrs()
      |> Map.merge(attrs)
      |> Map.put("host", host)

    Sites.create_site!(changes)
  end

  def insert_many(arg, attrs \\ %{})

  def insert_many(number, attrs) when is_integer(number) do
    Enum.to_list(0..number)
    |> Enum.map(fn n -> insert_one(n, attrs) end)
  end

  def insert_many(hosts, attrs) do
    hosts
    |> Enum.map(fn host -> insert_one(host, attrs) end)
  end

  defp generate_local_name(0), do: "localhost"
  defp generate_local_name(site_number), do: "site-#{site_number}.com"
end
