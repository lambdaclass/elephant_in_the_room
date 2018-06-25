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

  def show_link_with_date(conn, post) do
    year = post.inserted_at.year
    month = post.inserted_at.month
    day = post.inserted_at.day

    if conn.host != "localhost",
      do: post_path(conn, :public_show, year, month, day, post.slug),
      else: local_post_path(conn, :public_show, post.site.id, year, month, day, post.slug)
  end
end
