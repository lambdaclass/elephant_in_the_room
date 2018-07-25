defmodule ElephantInTheRoomWeb.Faker.Magazine do
  alias ElephantInTheRoom.Sites
  alias ElephantInTheRoomWeb.Faker.Utils

  defp default_attrs do
    %{
      "title" => Faker.Industry.sub_sector(),
      "description" => Faker.Lorem.sentence(10),
      "cover" => Utils.get_image_path(),
    }
  end

  def insert_one(%{"site_id" => _site_id} = attrs) do
    changes =
      Map.merge(default_attrs(), attrs)
      |> Utils.fake_image_upload

    case Sites.create_magazine(changes) do
      {:ok, magazine} ->
        magazine
      {:error, _} ->
        insert_one(attrs)
    end
  end

  def insert_many(n, attrs \\ %{}) do
    Enum.to_list(1..n)
    |> Enum.map(fn _ -> insert_one(attrs) end)
  end
end
