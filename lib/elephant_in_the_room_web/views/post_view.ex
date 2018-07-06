defmodule ElephantInTheRoomWeb.PostView do
  use ElephantInTheRoomWeb, :view
  alias ElephantInTheRoom.Sites.Post
  alias ElephantInTheRoom.Sites
  alias ElephantInTheRoom.Repo

  def mk_assigns(conn, assigns, site, post) do
    assigns
    |> Map.put(:action, site_post_path(conn, :update, site, post))
    |> Map.put(:categories, site.categories)
  end

  def mk_assigns(conn, assigns, site) do
    if !Map.has_key?(assigns, "categories") do
      Map.put(assigns, :action, site_post_path(conn, :create, site))
    else
      Map.put(assigns, :action, site_post_path(conn, :create, site, assigns.categories))
    end
  end

  def show_categories(site) do
    site.categories
    |> Enum.map(fn category -> category.name end)
  end

  def get_authors_options() do
    authors = Sites.list_authors()
    options = Enum.map(authors, &{&1.name, &1.id})
    default_option = {"-", ""}
    [default_option | options]
  end

  def show_selected_categories(post) do
    if Map.has_key?(post, "categories") do
      Enum.map(post.categories, fn category -> category.name end)
    else
      []
    end
  end

  def show_content(%Post{rendered_content: content}), do: content

  def put_commas(post, key) do
    if Map.has_key?(post, key) do
      post = Repo.preload(post, key)

      Map.get(post, key)
      |> Enum.map(fn t -> t.name end)
      |> Enum.intersperse(", ")
    else
      ""
    end
  end

  def show_featured_category(%Post{categories: categories}) do
    case categories do
      [] -> ""
      [featured_category | _] -> featured_category.name
    end
  end

  # 'Just now' if it's less than 5 minutes.
  # Show the minutes if higher than 5 minutes.
  # After 60 minutes, should show hours.
  # After 24 hours should show days.
  # After 14 days should show the plain date of the post.
  @one_minute 60
  @five_minutes 300
  @one_hour 3600
  @one_day 86400
  @one_day_and_few_hours @one_day + 5 * @one_hour
  @two_weeks 1_209_600

  defp format_diff(diff, _date) when diff <= @five_minutes, do: {:now, "just now"}

  defp format_diff(diff, _date) when diff < @one_hour,
    do: {:minutes, "#{div(diff, @one_minute)} minutes ago"}

  defp format_diff(diff, _date) when diff > @one_hour,
    do: {:hours, "#{div(diff, @one_hour)} hours ago"}

  defp format_diff(diff, _date) when diff <= @one_day_and_few_hours, do: {:day, "a day ago"}

  defp format_diff(diff, _date) when diff > @one_day_and_few_hours,
    do: {:days, "#{div(diff, @one_day)} days ago"}

  defp format_diff(diff, date) when diff > @two_weeks,
    do: {:date, "on #{date.day}-#{date.month}-#{date.year}"}

  def show_date(date) do
    now = NaiveDateTime.utc_now()
    {_res, msg} = format_diff(NaiveDateTime.diff(now, date), date)
    msg
  end

  def show_tag_link(conn, site, tag) do
    if conn.host != "localhost",
      do: tag_path(conn, :public_show, tag.id),
      else: local_tag_path(conn, :public_show, site.id, tag.id)
  end

  def show_site_link(conn, site) do
    if conn.host != "localhost",
      do: site_path(conn, :public_show),
      else: local_site_path(conn, :public_show, site)
  end

  def show_category_link(conn, site, category) do
    if conn.host != "localhost",
      do: category_path(conn, :public_show, category.id),
      else: local_category_path(conn, :public_show, site, category.id)
  end

  def show_link(conn, site, post) do 
    year = post.inserted_at.year
    month = post.inserted_at.month
    day = post.inserted_at.day

    if conn.host != "localhost",
      do: post_path(conn, :public_show, year, month, day, post.slug),
      else: local_post_path(conn, :public_show, site.id, year, month, day, post.slug)

  end

end
