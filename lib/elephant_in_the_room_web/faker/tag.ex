defmodule ElephantInTheRoomWeb.Faker.Tag do
  alias ElephantInTheRoom.Posts
  require Logger

  defp default_attrs do
    %{
      "name" => Faker.Beer.hop()
    }
  end

  def insert_one(attrs \\ %{}) do
    changes = Map.merge(default_attrs(), attrs)

    case Posts.create_tag(attrs["site"], changes) do
      {:ok, tag} ->
        tag

      {:error, error} ->
        error
        |> Kernel.inspect()
        |> Logger.warn()

        insert_one(attrs)
    end
  end

  def insert_many(n, attrs \\ %{}) do
    Enum.to_list(1..n)
    |> Enum.map(fn _ -> insert_one(attrs) end)
  end
end
