defmodule ElephantInTheRoomWeb.ImageController do
  use ElephantInTheRoomWeb, :controller
  alias ElephantInTheRoom.Sites

  def get_image(conn, %{"id" => img_id}) do
    img = Sites.get_image!(img_id)

    conn
    |> send_resp(200, img.binary)
  end

  def save_binary_image(conn, _params) do
    {:ok, raw_body, conn} = read_body(conn)

    type =
      :proplists.get_value("content-type", conn.req_headers)
      |> String.split("/")
      |> List.last()

    name = generate_name(type)

    {:ok, saved_image} = Sites.create_image(%{"name" => name, "binary" => raw_body})

    if is_image?(type) do
      conn
      |> send_resp(202, "#{saved_image.id}")
    else
      conn
      |> send_resp(415, "The file is not an image.")
    end
  end

  def search_image(conn, %{"name" => img_name}) do
    img = Sites.get_image_by_name!(img_name)

    conn
    |> send_resp(200, img.binary)
  end

  def save_image(conn, %{"url" => url}) do
    image = HTTPoison.get!(url, [], hackney: [{:follow_redirect, true}])

    type =
      :proplists.get_value("content-type", conn.req_headers)
      |> String.split("/")
      |> List.last()

    name = generate_name(type)

    {:ok, saved_image} = Sites.create_image(%{"name" => name, "binary" => image.body})

    conn
    |> send_resp(202, "#{saved_image.id}")
  end

  defp generate_name(extension) do
    Ecto.UUID.generate() <> "." <> extension
  end

  defp is_image?("png"), do: true
  defp is_image?("bmp"), do: true
  defp is_image?("jpeg"), do: true
  defp is_image?(_type), do: false
end
