defmodule ElephantInTheRoomWeb.SiteView do
  use ElephantInTheRoomWeb, :view
  alias ElephantInTheRoom.{Posts.Post, Sites.Site, Sites.Author}
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

  def show_link_with_date(conn, post) do
    year = post.inserted_at.year
    month = post.inserted_at.month
    day = post.inserted_at.day

    post_path(conn, :public_show, year, month, day, post.slug)
  end

  def show_site_link(conn), do: site_path(conn, :public_show)

  def render_shared(template, assigns \\ []),
    do: render(SharedPostCardView, template, assigns)

  def get_abstract_to_display(%Post{abstract: abstract}, _count)
      when abstract == nil,
      do: ""

  def get_abstract_to_display(%Post{abstract: abstract}, count)
      when count < 0 or count == nil,
      do: abstract

  def get_abstract_to_display(%Post{abstract: abstract}, count) do
    {split, _} = String.split_at(abstract, count)
    split
  end

  def get_author_description_to_display(%Author{description: description})
      when description != nil do
    {split, _} = String.split_at(description, 50)
    split
  end

  def get_author_description_to_display(_), do: nil

  def get_authors(%Site{authors: authors}, amount), do: Enum.take(authors, amount)

  # This is a 'place-holder' function, the intent is that later this
  # will be replaced for a function that can determine which post
  # belongs to each position/section in the landing page using
  # a more eleborated criteria
  def get_posts(%Site{posts: posts}, %{
        section_1_amount: amount1,
        section_2_amount: amount2,
        section_3_amount: amount3
      }) do
    {s1_from, s1_to} = {0, amount1}
    {s2_from, s2_to} = {s1_to, s1_to + amount2}
    {s3_from, s3_to} = {s2_to, s2_to + amount3}

    %{
      section1: take_range_from_list(posts, s1_from, s1_to),
      section2: take_range_from_list(posts, s2_from, s2_to),
      section3: take_range_from_list(posts, s3_from, s3_to)
    }
  end

  def take_range_from_list(list, from, to) do
    take_range_from_list(list, [], 0, from, to)
    |> Enum.reverse()
  end

  defp take_range_from_list([h | t], acc, current, from, to) do
    cond do
      current < from -> take_range_from_list(t, acc, current + 1, from, to)
      current >= to -> acc
      true -> take_range_from_list(t, [h | acc], current + 1, from, to)
    end
  end

  defp take_range_from_list([], acc, _current, _from, _to), do: acc
end
