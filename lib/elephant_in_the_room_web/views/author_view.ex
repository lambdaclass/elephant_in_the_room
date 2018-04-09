defmodule ElephantInTheRoomWeb.AuthorView do
  use ElephantInTheRoomWeb, :view
  alias ElephantInTheRoom.Repo

  def number_of_published_posts(author) do
    author
    |> Repo.preload(:posts)
    |> (fn author -> length(author.posts) end).()
  end
end
