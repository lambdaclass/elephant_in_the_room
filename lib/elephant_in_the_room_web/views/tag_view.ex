defmodule ElephantInTheRoomWeb.TagView do
  use ElephantInTheRoomWeb, :view
  alias ElephantInTheRoom.Repo
  alias ElephantInTheRoomWeb.Utils.Utils
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

  def tag_link(conn, tag) do
    tag_path(conn, :public_show, URI.encode(tag.name))
    |> Utils.generate_absolute_url(conn)
  end
end
