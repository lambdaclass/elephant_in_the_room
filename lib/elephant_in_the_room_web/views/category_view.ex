defmodule ElephantInTheRoomWeb.CategoryView do
  use ElephantInTheRoomWeb, :view
  import ElephantInTheRoomWeb.Utils.ViewUtils

  def get_top_featured_post(_conn, posts) do
    case posts do
      [top | _] -> {:ok, top}
      [] -> {:error, :no_top_featured}
    end
  end

  def get_important_posts(_conn, posts) do
    case posts do
      [_top | rest] ->
        {:ok, Enum.take(rest, 3)}
      [] -> {:error, :no_important_posts}
    end
  end

  def get_normal_posts(_conn, posts) do
    case posts do
      [_ | normal_posts] ->
        {:ok, Enum.drop(normal_posts, 4)}
      _ -> {:error, :no_normal_posts}
    end
  end

  
end
