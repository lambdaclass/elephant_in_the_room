defmodule ElephantInTheRoomWeb.CategoryView do
  use ElephantInTheRoomWeb, :view
  alias ElephantInTheRoom.Repo

  def load_posts(category) do
    category_with_posts =
      category
      |> Repo.preload(:posts)

    category_with_posts.posts
  end
end
