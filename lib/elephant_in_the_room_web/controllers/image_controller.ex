defmodule ElephantInTheRoomWeb.ImageController do
  use ElephantInTheRoomWeb, :controller
  alias ElephantInTheRoom.Sites

  def get_image(conn, %{"id" => img_id}) do
    img = Sites.get_image!(img_id)

    conn
    |> send_resp(200, img.binary)
  end

  def search_image(conn, %{"name" => img_name}) do
    img = Sites.get_image_by_name!(img_name)

    conn
    |> send_resp(200, img.binary)
  end

  def save_image(conn, %{"url" => url}) do
    image = HTTPoison.get!(url, [], hackney: [{:follow_redirect, true}])

    type =
      :proplists.get_value("Content-Type", image.headers)
      |> String.split("/")
      |> List.last()

    {:ok, saved_image} = Sites.create_image(%{"binary" => image.body, "type" => type})

    conn
    |> send_resp(202, "Ok #{saved_image.id}")
  end
end
