defmodule ElephantInTheRoomWeb.Utils.ViewUtils do
  alias Phoenix.View
  alias ElephantInTheRoomWeb.SharedPostCardView
  alias ElephantInTheRoom.Repo

  def compare(1, 1), do: :unique_page

  def compare(x, x), do: :equal

  def compare(1, _y), do: :first

  def compare(x, y) when x > y, do: :greater

  def compare(x, y) when x < y, do: :lesser

  def shared_render_posts_card(conn, posts, assigns) do
    posts =
      posts
      |> Enum.map(fn p ->
        Repo.preload(p, [:categories, :tags, :author])
      end)

    all_assigns = Enum.concat([posts: posts, conn: conn], assigns)

    View.render(
      SharedPostCardView,
      "_shared_post_card.html",
      all_assigns
    )
  end
end
