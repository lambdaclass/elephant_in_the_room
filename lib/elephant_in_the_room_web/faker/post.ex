defmodule ElephantInTheRoomWeb.Faker.Post do
  alias ElephantInTheRoom.{Posts, Sites}
  alias ElephantInTheRoomWeb.Faker.Utils
  require Logger

  def default_attrs do
    %{
      "content" => generate_content(),
      "cover" => Utils.get_image_path(),
      "title" => Enum.join(Faker.Lorem.words(7), " "),
      "type" => Enum.random(["text", "video", "audio"]),
      "abstract" => generate_abstract(30),
      "inserted_at" => generate_inserted_at(),
      "slug" => ""
    }
  end

  def insert_one(%{"magazine_id" => _magazine_id} = attrs) do
    new_attrs =
      default_attrs()
      |> Map.merge(attrs)
      |> Map.put("type", "text")

    {:ok, post} =
      new_attrs
      |> Utils.fake_image_upload()
      |> Posts.create_magazine_post()

    post
  end

  def insert_one(attrs) do
    changes =
      default_attrs()
      |> Map.merge(attrs)
      |> Utils.fake_image_upload()
      |> put_media()

    {:ok, post} = Posts.create_post(attrs["site"], changes)

    post
  end

  def insert_many(n, attrs \\ %{}) do
    Enum.to_list(1..n)
    |> Enum.map(fn _ -> insert_one(attrs) end)
  end

  defp put_media(%{"type" => "audio"} = attrs) do
    sample =
      [
        ~s(<iframe width="100%" height="300" scrolling="no" frameborder="no" allow="autoplay" src="https://w.soundcloud.com/player/?url=https%3A//api.soundcloud.com/tracks/481942059&color=%23ff5500&auto_play=false&hide_related=false&show_comments=true&show_user=true&show_reposts=false&show_teaser=true&visual=true"></iframe>),
        ~s(<iframe width="100%" height="300" scrolling="no" frameborder="no" allow="autoplay" src="https://w.soundcloud.com/player/?url=https%3A//api.soundcloud.com/tracks/306467330&color=%23ff5500&auto_play=false&hide_related=false&show_comments=true&show_user=true&show_reposts=false&show_teaser=true&visual=true"></iframe>),
        ~s(<iframe width="100%" height="300" scrolling="no" frameborder="no" allow="autoplay" src="https://w.soundcloud.com/player/?url=https%3A//api.soundcloud.com/tracks/414446448&color=%23ff5500&auto_play=false&hide_related=false&show_comments=true&show_user=true&show_reposts=false&show_teaser=true&visual=true"></iframe>),
        ~s(<iframe width="100%" height="300" scrolling="no" frameborder="no" allow="autoplay" src="https://w.soundcloud.com/player/?url=https%3A//api.soundcloud.com/tracks/415745424&color=%23ff5500&auto_play=false&hide_related=false&show_comments=true&show_user=true&show_reposts=false&show_teaser=true&visual=true"></iframe>)
      ]

    Map.put(attrs, "media", Enum.random(sample))
  end

  defp put_media(%{"type" => "video"} = attrs) do
    sample =
      [
        ~s(https://www.youtube.com/watch?v=kEPakJDkTOk),
        ~s(https://www.youtube.com/watch?v=lj4WbJoFYlE),
        ~s(https://www.youtube.com/watch?v=jrTMMG0zJyI),
        ~s(https://www.youtube.com/watch?v=LsBrT6vbQa8)
      ]

    Map.put(attrs, "media", Enum.random(sample))
  end

  defp put_media(attrs), do: attrs

  defp generate_inserted_at do
    now = NaiveDateTime.utc_now()
    hour = :rand.uniform(23)
    minute = :rand.uniform(59)
    second = :rand.uniform(59)

    case NaiveDateTime.new(now.year, now.month, now.day, hour, minute, second) do
      {:ok, time} -> time
      _ -> generate_inserted_at()
    end
  end

  defp generate_content do
    [gen_text(20), gen_md_image(), gen_text(20)] |> Enum.join("\n\n")
  end

  defp generate_abstract(max_words) do
    max_words
    |> :rand.uniform()
    |> Faker.Lorem.words()
    |> Enum.join(" ")
  end

  defp gen_text(length), do: gen_text(length, :rand.uniform(5))

  defp gen_text(length, paragraph_count) do
    paragraphs =
      for _ <- 0..paragraph_count do
        Faker.Lorem.paragraph(:rand.uniform(length))
      end

    Enum.join(paragraphs, "\n\n")
  end

  def gen_md_image, do: gen_md_image_path(Utils.get_image_path())

  def gen_md_image_path(path) do
    description = Faker.Lorem.word()
    image_content = File.read!(path)

    {:ok, image} = Sites.create_image(%{name: Ecto.UUID.generate(), binary: image_content})
    "![#{description}](/images/#{image.name})"
  end
end
