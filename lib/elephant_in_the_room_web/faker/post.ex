defmodule ElephantInTheRoomWeb.Faker.Post do
  alias ElephantInTheRoom.Sites

  # author 1
  # site 1
  # categories N
  # tags N
  def default_attrs do
    %{
      :content => generate_content(),
      :image => Faker.Avatar.image_url(),
      :title => Faker.Lorem.Shakespeare.romeo_and_juliet(),
      :abstract => Faker.Lorem.paragraph(2),
      :slug => ""
    }
  end

  def insert_one(attrs \\ %{}) do
    changes = Map.merge(default_attrs(), attrs)

    {:ok, post} = Sites.create_post(attrs[:site], changes)

    post
  end

  def insert_many(n, attrs \\ %{}) do
    Enum.to_list(1..n)
    |> Enum.map(fn _ -> insert_one(attrs) end)
  end

  defp generate_content() do
    Faker.Lorem.paragraph(20)
    # generate random markdown text
  end
end
