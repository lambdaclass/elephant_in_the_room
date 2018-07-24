defmodule ElephantInTheRoomWeb.Faker.Post do
  alias ElephantInTheRoom.Sites
  alias ElephantInTheRoomWeb.Faker.Utils
  require Logger

  # author 1
  # site 1
  # categories N
  # tags N
  def default_attrs do
    %{
      "content" => generate_content(),
      "cover" => Utils.get_image_path(),
      "title" => Enum.join(Faker.Lorem.words(7), " "),
      "abstract" => Faker.Lorem.paragraph(10),
      "slug" => ""
    }
  end

  def insert_one(attrs \\ %{}) do
    changes = Map.merge(default_attrs(), attrs)
    new_changes = Utils.fake_image_upload(changes)
    {:ok, post} = Sites.create_post(attrs["site"], new_changes)

    post
  end

  def insert_many(n, attrs \\ %{}) do
    Enum.to_list(1..n)
    |> Enum.map(fn _ -> insert_one(attrs) end)
  end

  defp generate_content() do
    [gen_text(20), gen_md_image(), gen_text(20)] |> Enum.join("\n\n")
  end

  defp gen_text(length), do: gen_text(length, :rand.uniform(5))
  defp gen_text(length, paragraph_count) do
    paragraphs = for _ <- 0 .. paragraph_count do
      Faker.Lorem.paragraph(:rand.uniform(length))
    end
    Enum.join(paragraphs, "\n\n")
  end

  defp gen_md_image() do
    description = Faker.Lorem.word()
    image_content = File.read!(Utils.get_image_path())

    {:ok, image} = Sites.create_image(%{name: Ecto.UUID.generate(), binary: image_content})
    "![#{description}](/images/#{image.name})"
  end
end
