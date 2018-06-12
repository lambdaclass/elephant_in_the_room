defmodule ElephantInTheRoomWeb.Faker.Utils do
  # download the image from source
  def download_image(source) do
    {:ok, resp} = HTTPoison.request(:get, source, "", [], [hackney: [{:follow_redirect, true}]])
    %{body: body} = resp
    body
  end

  def fake_image_upload(attrs, format \\ "png") do
    {:ok, file} = Plug.Upload.random_file("gen")
    content = download_image(attrs["image"])
    File.write(file, content)

    uploaded_image = %Plug.Upload{
      path: file,
      content_type: "image/" <> format,
      filename: file |> Path.split() |> List.last() |> (fn name -> name <> "." <> format end).()
    }

    Map.put(attrs, "image", uploaded_image)
  end
end
