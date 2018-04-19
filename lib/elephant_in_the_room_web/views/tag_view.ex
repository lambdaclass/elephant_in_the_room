defmodule ElephantInTheRoomWeb.TagView do
  use ElephantInTheRoomWeb, :view
  alias ElephantInTheRoom.Repo
  alias ElephantInTheRoom.Sites.Post
  import Ecto.Query

  def number_of_posts(tag) do
    from(
      p in "posts_tags",
      where: p.tag_id == ^tag.id,
      select: count(p.post_id)
    )
    |> Repo.one()
  end

  def latest_posts(tag, amount \\ 4) do
    tag_with_posts = Repo.preload(tag, :posts)
    Enum.take(tag_with_posts.posts, amount)
  end
end
