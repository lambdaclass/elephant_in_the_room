defmodule ElephantInTheRoom.Sites.Featured do
  import Ecto.Query, warn: false
  alias ElephantInTheRoom.Sites.Post
  alias ElephantInTheRoom.Repo

  defmodule FeaturedLevel do
    defstruct [:level, :fetch_limit]
  end

  def get_featured_levels(:fetcheable) do
    [_|Fetcheable] = get_featured_levels()
    Fetcheable
  end
  def get_featured_levels() do
    [
      %FeaturedLevel{level: 0, fetch_limit: :no_fetch},
      %FeaturedLevel{level: 1, fetch_limit: 1},
      %FeaturedLevel{level: 2, fetch_limit: 2},
      %FeaturedLevel{level: 3, fetch_limit: 4},
      %FeaturedLevel{level: 4, fetch_limit: 8}
    ]
  end

  def get_featured_posts(%FeaturedLevel{fetch_limit: :no_fetch}, _), do: []
  def get_featured_posts(%FeaturedLevel{level: level, fetch_limit: limit}, site_id) do
    posts_query = from p in Post,
      where: p.featured_level == ^level and p.site_id == ^site_id,
      order_by: [desc: p.inserted_at],
      limit: ^limit,
      preload: [:author]
    Repo.all(posts_query)
  end

  def get_all_featured_posts(site_id) do
    Enum.map(get_featured_levels(:fetcheable), fn (level) ->
      {level, get_featured_posts(level, site_id)}
    end)
  end

  def get_all_featured_posts_ensure_filled(site_id, additive_limit \\ 0) do
    featured_posts = get_all_featured_posts(site_id)
    aditional_posts = get_more_posts_from_featured(featured_posts, additive_limit, site_id)
    fill_featured_with_aditional(featured_posts, aditional_posts)
  end

  defp amount_of_needed_featured_posts(featured_posts) do
    Enum.reduce(featured_posts, 0, fn({%{fetch_limit: limit}, posts}, count) ->
      count + (limit - length(posts))
    end)
  end

  defp featured_posts_ids(featured_posts) do 
    Enum.reduce(featured_posts, [], fn({_, posts}, acc) ->
      ids = Enum.map(posts, &(&1.id))
      ids ++ acc
    end)
  end 

  defp get_more_posts_from_featured(featured_posts, additive_limit, site_id) do
    featured_posts_ids = featured_posts_ids(featured_posts)
    amount_of_needed_featured_posts = amount_of_needed_featured_posts(featured_posts)
    limit = amount_of_needed_featured_posts + additive_limit
    post_query = from p in Post,
      where: p.site_id == ^site_id  and not p.id in ^featured_posts_ids,
      order_by: [desc: p.inserted_at],
      limit: ^limit,
      preload: [:author]
    Repo.all(post_query)
  end

  defp fill_featured_with_aditional(featured_posts, aditional_posts), do: 
    fill_featured_with_aditional(featured_posts, aditional_posts, [])
  defp fill_featured_with_aditional([], aditional_posts, acc), do:
    {Enum.reverse(acc), aditional_posts}
  defp fill_featured_with_aditional([{%{fetch_limit: limit} = level, posts_of_level} | featured_posts], aditional_posts, acc) do
    necessary_amount = limit - length(posts_of_level)
    {posts_to_add, remainding_posts} = Enum.split(aditional_posts, necessary_amount)
    featured_filled = {level, posts_of_level ++ posts_to_add }
    fill_featured_with_aditional(featured_posts, remainding_posts, [featured_filled | acc])
  end


end
