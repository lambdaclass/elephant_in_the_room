defmodule ElephantInTheRoomWeb.AuthorView do
  use ElephantInTheRoomWeb, :view
  alias ElephantInTheRoom.{Repo, Sites.Post}
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
    |> replace_host(conn, post)
  end

  defp replace_host(relative_path, conn, post) do
    "#{conn.scheme}://#{post.site.host}:#{conn.port}#{relative_path}"
  end
end
