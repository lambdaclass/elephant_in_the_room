defmodule ElephantInTheRoomWeb.Faker.User do
  alias ElephantInTheRoom.Sites

  # author 1
  # site 1
  # categories N
  # tags N
  def default_attrs do
    %{
      content: generate_content(),
      image: Faker.Avatar.image_url(),
      title: Faker.Lorem.Shakespeare.romeo_and_juliet(),
      abstract: Faker.Lorem.paragraph(2)
    }
  end

  def insert_one(attrs \\ %{}) do
    changes = Map.merge(default_attrs, attrs)

    Sites.create_post(attrs[:site], changes)
  end

  def insert_many(site, attrs \\ %{}, n) do
    Enum.to_list(1..n)
    |> Enum.each(fn _ -> insert_one(site, attrs) end)
  end

  defp generate_content() do
    # generate random markdown text
  end
end
