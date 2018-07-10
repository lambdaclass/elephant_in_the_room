defmodule ElephantInTheRoomWeb.SiteView do
  use ElephantInTheRoomWeb, :view
  alias ElephantInTheRoom.Sites.Post
  alias ElephantInTheRoom.Sites.Site

  alias ElephantInTheRoomWeb.SharedPostCardView

  def get_top_featured_post(_conn, posts) do
    case posts do
      [top | _] -> {:ok, top}
      [] -> {:error, :no_top_featured}
    end
  end

  def get_important_posts(_conn, posts) do
    case posts do
      [_top | rest] ->
        {:ok, Enum.take(rest, 3)}

      [] ->
        {:error, :no_important_posts}
    end
  end

  def get_important_posts_left(_conn, posts) do
    case posts do
      [_top | rest] ->
        {:ok, Enum.take(rest, 2)}

      [] ->
        {:error, :no_important_posts_left}
    end
  end

  def get_important_posts_right(_conn, posts) do
    case posts do
      [_ | rest] ->
        {:ok, rest |> Enum.drop(2) |> Enum.take(4)}

      _ ->
        {:error, :no_important_posts_right}
    end
  end

  def get_normal_posts(_conn, posts) do
    case posts do
      [_ | normal_posts] ->
        {:ok, Enum.drop(normal_posts, 6)}

      _ ->
        {:error, :no_normal_posts}
    end
  end

  def number_of_entries(entries, entries_per_page) do
    max(entries_per_page - entries, entries)
  end

  def show_link_with_date(conn, site, post) do
    year = post.inserted_at.year
    month = post.inserted_at.month
    day = post.inserted_at.day

    if conn.host != "localhost",
      do: post_path(conn, :public_show, year, month, day, post.slug),
      else: local_post_path(conn, :public_show, site.id, year, month, day, post.slug)
  end

  def show_site_link(site, conn) do
    if conn.host != "localhost",
      do: site_path(conn, :public_show),
      else: local_site_path(conn, :public_show, site.id)
  end

  def render_shared(template, assigns \\ []) do
    render(SharedPostCardView, template, assigns)
  end

  def get_abstract_to_display(%Post{abstract: abstract}, count) when
    abstract == nil, do: ""
  def get_abstract_to_display(%Post{abstract: abstract}, count) when
    count < 0 or count==nil, do: abstract
  def get_abstract_to_display(%Post{abstract: abstract}, count) do
    {split, _} = String.split_at(abstract, count) 
    split
  end

  def get_authors(%Site{authors: authors}, amount) do
    Enum.take(authors, amount)
    |> fill_with_nil(amount)
  end

  # This is a 'place-holder' function, the intent is that later this
  # will be replaced for a function that can determine which post
  # belongs to each position/section in the landing page using
  # a more eleborated criteria
  def get_posts(%Site{posts: posts}, %{section_1_amount: amount1,
      section_2_amount: amount2, section_3_amount: amount3,
      section_4_amount: amount4, section_5_amount: amount5}) do
    {s1_from, s1_to} = {0, amount1-1}
    {s2_from, s2_to} = {s1_to, s1_to + amount2 - 1}
    {s3_from, s3_to} = {s2_to, s2_to + amount3 - 1}
    {s4_from, s4_to} = {s3_to, s3_to + amount4 - 1}
    {s5_from, s5_to} = {s4_to, s4_to + amount5 - 1}
    %{section1: take_range_from_list(posts, s1_from, s1_to),
      section2: take_range_from_list(posts, s2_from, s2_to),
      section3: take_range_from_list(posts, s3_from, s3_to),
      section4: take_range_from_list(posts, s4_from, s4_to),
      section5: take_range_from_list(posts, s5_from, s5_to)}
  end

  def take_range_from_list(list, from, to) do
    amount = to - from + 1
    range = take_range_from_list(list, [], 0, from, to)
      |> Enum.reverse
    fill_with_nil(range, amount)
  end
  defp take_range_from_list([h|t], acc, current, from, to) do
    cond do
      current < from -> take_range_from_list(t, acc, current + 1, from, to)
      current > to -> acc
      true -> take_range_from_list(t, [h|acc], current+1, from, to)
    end
  end
  defp take_range_from_list([], acc, current, from, to) do
    acc
  end

  defp fill_with_nil(list, desired_size) do
    amount_to_fill = desired_size - length(list)
    fill =
      if amount_to_fill > 0 do
        for _ <- 0 .. amount_to_fill - 1, do: nil
      else
        []
      end
    list ++ fill
  end

end
