defmodule ElephantInTheRoomWeb.Faker.Utils do
  # download the image from source
  def download_image(source) do
    {:ok, resp} = HTTPoison.get(source)
    %{body: body} = resp
    body
  end

  def fake_image_upload(attrs) do
    {:ok, file} = Plug.Upload.random_file("gen")
    content = download_image(attrs["image"])
    File.write(file, content)

    uploaded_image = %Plug.Upload{
      path: file,
      content_type: "image/png",
      filename: file |> Path.split() |> List.last() |> (fn name -> name <> ".png" end).()
    }

    Map.put(attrs, "image", uploaded_image)
  end

  # "image" => %Plug.Upload{
  #  content_type: "image/jpeg",
  #  filename: "2772065.jpeg",
  #  path: "/tmp/plug-1525/multipart-1525359107-788105974475642-2"
  # }
end
