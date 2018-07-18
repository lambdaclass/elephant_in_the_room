defmodule ElephantInTheRoomWeb.Faker.Tag do
  alias ElephantInTheRoom.Sites
  require Logger

  defp default_attrs do
    %{
      "name" => Faker.Beer.hop(),
      "color" => Faker.Color.rgb_hex()
    }
  end

  def insert_one(attrs \\ %{}) do
    changes = Map.merge(default_attrs(), attrs)

    case Sites.create_tag(attrs["site"], changes) do
      {:ok, tag} ->
        tag
      {:error, error} ->
        Kernel.inspect(error) |> Logger.warn
        insert_one(attrs)
    end
  end

  def insert_many(n, attrs \\ %{}) do
    Enum.to_list(1..n)
    |> Enum.map(fn _ -> insert_one(attrs) end)
  end
end
