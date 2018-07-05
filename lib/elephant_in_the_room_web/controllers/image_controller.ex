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

    name = generate_name()

    {:ok, saved_image} = Sites.create_image(%{"name" => name, "binary" => raw_body})

    conn
    |> send_resp(202, "#{saved_image.id}")
  end

  def search_image(conn, %{"name" => img_name}) do
    img = Sites.get_image_by_name!(img_name)

    conn
    |> send_resp(200, img.binary)
  end

  def save_image(conn, %{"url" => url}) do
    image = HTTPoison.get!(url, [], hackney: [{:follow_redirect, true}])

    name = generate_name()

    {:ok, saved_image} = Sites.create_image(%{"name" => name, "binary" => image.body})

    conn
    |> send_resp(202, "#{saved_image.id}")
  end

  defp generate_name() do
    :crypto.hash(:sha256, "image" <> to_string(:erlang.monotonic_time()))
  end
end
