defmodule ElephantInTheRoomWeb.Faker.Utils do
  # download the image from source
  def download_image(source) do
    {:ok, resp} = HTTPoison.get(source)
    %{body: body} = resp
    body
  end
end
