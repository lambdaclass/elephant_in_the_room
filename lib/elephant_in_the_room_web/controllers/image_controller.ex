defmodule ElephantInTheRoomWeb.ImageController do
  use ElephantInTheRoomWeb, :controller
  alias ElephantInTheRoom.Sites

  def get_image(conn, %{"id" => img_id}) do
    img = Sites.get_image!(img_id)

    conn
    |> put_resp_content_type(img.type, "utf-8")
    |> send_resp(200, img.binary)
  end

  def save_binary_image(conn, _params) do
    {:ok, raw_body, conn} = read_body(conn)

    type =
      :proplists.get_value("content-type", conn.req_headers)
      |> String.split("/")
      |> List.last()

    {:ok, saved_image} = Sites.create_image(%{"binary" => raw_body, "type" => type})

    conn
    |> send_resp(202, "Ok #{saved_image.id}")
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
