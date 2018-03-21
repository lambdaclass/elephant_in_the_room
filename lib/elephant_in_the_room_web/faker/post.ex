defmodule ElephantInTheRoomWeb.Faker.Post do
  alias ElephantInTheRoom.Sites

  # author 1
  # site 1
  # categories N
  # tags N
  def default_attrs do
    %{
      "content" => generate_content(),
      "image" => "https://picsum.photos/1024/786?image=#{:rand.uniform(1050)}",
      "title" => Enum.join(Faker.Lorem.words(7), " "),
      "abstract" => Faker.Lorem.paragraph(10),
      "slug" => ""
    }
  end

  def insert_one(attrs \\ %{}) do
    changes = Map.merge(default_attrs(), attrs)

    {:ok, post} = Sites.create_post(attrs["site"], changes)

    post
  end

  def insert_many(n, attrs \\ %{}) do
    Enum.to_list(1..n)
    |> Enum.map(fn _ -> insert_one(attrs) end)
  end

  defp generate_content() do
    Faker.Lorem.paragraph(40)
  end
end
