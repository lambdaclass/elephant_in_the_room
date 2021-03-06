defmodule ElephantInTheRoomWeb.Faker.Utils do
  # download the image from source
  defp download_image(source, trials) when trials < 1 do
    raise "can not download #{source}"
  end

  defp download_image(source, trials) do
    result = HTTPoison.request(:get, source, "", [], hackney: [{:follow_redirect, true}])

    case result do
      {:ok, %{body: body}} ->
        body

      _ ->
        download_image(source, trials - 1)
    end
  end

  def download_image(source) do
    download_image(source, 8)
  end

  def fake_image_upload(%{"cover" => cover} = attrs) do
    %{"image" => image} = fake_image_upload(%{"image" => cover})
    %{attrs | "cover" => image}
  end

  def get_image_path_ads, do: get_image_path("for_ads")
  def get_image_path, do: get_image_path("for_posts")

  def get_image_path(path) do
    File.ls!("./images/#{path}")
    |> Enum.random()
    |> (fn image -> "./images/#{path}/#{image}" end).()
  end

  def fake_image_upload_ads(attrs, format \\ "png"),
    do: fake_image_upload(attrs, &get_image_path_ads/0, format)

  def fake_image_upload(attrs, format \\ "png"),
    do: fake_image_upload(attrs, &get_image_path/0, format)

  def fake_image_upload(attrs, image_path, format) do
    {:ok, file} = Plug.Upload.random_file("gen")
    content = File.read!(image_path.())
    File.write(file, content)

    uploaded_image = %Plug.Upload{
      path: file,
      content_type: "image/#{format}",
      filename: file |> Path.split() |> List.last() |> (fn name -> "#{name}.#{format}" end).()
    }

    Map.put(attrs, "image", uploaded_image)
  end

  def get_sites_config(path) do
    case File.read(path) do
      {:ok, content} ->
        hosts =
          content
          |> String.split("\n")
          |> Enum.filter(fn str -> str != "" end)

        {length(hosts), hosts}

      {:error, reason} ->
        IO.puts(reason)
        {nil, nil}
    end
  end
end
