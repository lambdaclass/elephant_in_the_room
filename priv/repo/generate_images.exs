defmodule ImageDownloader do
  defp download_image(source, trials) when trials < 1,
    do: raise("can not download #{source}")

  defp download_image(source, trials) do
    case HTTPoison.get(source, [], hackney: [{:follow_redirect, true}]) do
      {:ok, %{body: "{\"error\":\"Invalid image id\"}"}} ->
        download_image(gen_url(), trials - 1)

      {:ok, %{body: body} = res} ->
        type =
          :proplists.get_value("Content-Type", res.headers)
          |> String.split("/")
          |> List.last()

        %{name: "#{Ecto.UUID.generate()}.#{type}", body: body}

      _ ->
        download_image(gen_url(), trials - 1)
    end
  end

  def download_image(source), do: download_image(gen_url(), 100)

  def save_image(image, location), do: File.write("#{location}/#{image.name}", image.body)

  def gen_url(), do: "https://picsum.photos/1024/786?image=#{:rand.uniform(1050)}"
end

# Command used to compress the images:
# for i in `ls`; do convert $i -sampling-factor 4:2:0 -strip -quality 60 -interlace JPEG -colorspace sRGB "converted_$i" ; done

for n <- 1..30 do
  ImageDownloader.gen_url()
  |> ImageDownloader.download_image()
  |> ImageDownloader.save_image("./images")
end
