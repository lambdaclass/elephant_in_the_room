defmodule ElephantInTheRoomWeb.SiteView do
  use ElephantInTheRoomWeb, :view
  
  def get_top_featured_post(_conn, posts) do
    IO.puts("----\n")
    IO.puts(inspect(posts))
    case posts do
      [top | _] -> {:ok, top}
      [] -> {:error, :no_top_featured}
    end
  end

  def get_normal_posts(_conn, posts) do
    case posts do
      [_ | normal_posts] -> {:ok, normal_posts}
      _ -> {:error, :no_normal_posts}
    end
  end
  
end

