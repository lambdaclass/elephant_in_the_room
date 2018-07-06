defmodule ElephantInTheRoomWeb.Utils.ViewUtils do
  alias Phoenix.View
  alias ElephantInTheRoomWeb.SharedPostCardView
  alias ElephantInTheRoom.Repo

  def compare(1, 1), do: :unique_page

  def compare(x, x), do: :equal

  def compare(1, _y), do: :first

  def compare(x, y) when x > y, do: :greater

  def compare(x, y) when x < y, do: :lesser

  def page_pagination_check(page_number, total_pages) do
    show_left = page_number > 1
    show_right = total_pages > 1 && page_number < total_pages
    show_middle = show_left && show_right
    IO.inspect({show_left, show_right})
    {show_left, show_middle, show_right}
  end

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

  def image_url(nil) do
    ""
  end

  def image_url(url) do
    case String.contains?(url, "http") || String.contains?(url, "/images/search") do
      false ->
        "/images/search/" <> url
      true ->
        url
    end
  end
end
