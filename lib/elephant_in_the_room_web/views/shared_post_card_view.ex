defmodule ElephantInTheRoomWeb.SharedPostCardView do
  use ElephantInTheRoomWeb, :view
  alias ElephantInTheRoom.Sites.Post
  alias Plug.Conn

  def show_link_with_date(conn, site, post) do
    year = site.inserted_at.year
    month = site.inserted_at.month
    day = site.inserted_at.day
    slug = Post.slugified_title(post.title)

    new_conn = conn |> Conn.assign(:post, post)
    IO.puts("A:" <> inspect(Map.keys(new_conn.assigns)))
    post_path(new_conn, :public_show, site.id, year, month, day, slug)
  end
end
