defmodule ElephantInTheRoomWeb.Faker.Tag do
  alias ElephantInTheRoom.Sites

  defp default_attrs do
    %{
      :name => Faker.Pizza.cheese() <> to_string(:rand.uniform(10000))
    }
  end

  def insert_one(attrs \\ %{}) do
    changes = Map.merge(default_attrs(), attrs)

    {:ok, tag} = Sites.create_tag(attrs[:site], changes)
    tag
  end

  def insert_many(n, attrs \\ %{}) do
    Enum.to_list(1..n)
    |> Enum.map(fn _ -> insert_one(attrs) end)
  end
end
