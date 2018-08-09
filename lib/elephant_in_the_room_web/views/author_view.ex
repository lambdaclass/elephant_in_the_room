defmodule ElephantInTheRoomWeb.AuthorView do
  use ElephantInTheRoomWeb, :view
  alias ElephantInTheRoom.{Repo, Posts.Post}
  alias ElephantInTheRoomWeb.Utils.Utils
  import Ecto.Query

  def number_of_published_posts(author) do
    from(p in Post, where: p.author_id == ^author.id, select: count(p.id))
    |> Repo.one()
  end

  def show_link_with_date(conn, post) do
    year = post.inserted_at.year
    month = post.inserted_at.month
    day = post.inserted_at.day

    post_path(conn, :public_show, year, month, day, post.slug)
    |> Utils.generate_absolute_url(conn, post.site)
  end
end
