defmodule ElephantInTheRoomWeb.Faker.Ad do
  alias ElephantInTheRoom.Sites.Ad
  alias ElephantInTheRoomWeb.Faker.Post, as: PostFaker
  require Logger

  defp default_attrs do
    %{
      "name" => Faker.Pokemon.name,
      "pos" => :rand.uniform(10),
      "content" => PostFaker.gen_md_image()
    }
  end

  defp insert_one(attrs) do
    changes = Map.merge(default_attrs(), attrs)
    case Ad.create(attrs["site"], changes) do
      {:ok, ad} ->
        ad
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
