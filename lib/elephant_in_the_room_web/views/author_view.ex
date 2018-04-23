defmodule ElephantInTheRoomWeb.AuthorView do
  use ElephantInTheRoomWeb, :view
  alias ElephantInTheRoom.Repo
  alias ElephantInTheRoom.Sites.Post
  import Ecto.Query

  def number_of_published_posts(author) do
    from(
      p in Post,
      where: p.author_id == ^author.id,
      select: count(p.id)
    )
    |> Repo.one()
  end
end
