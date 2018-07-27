defmodule ElephantInTheRoom.Sites.Featured do
  import Ecto.Query, warn: false
  alias ElephantInTheRoom.Sites.Post
  alias ElephantInTheRoom.Repo
  alias Ecto.Multi
  @default_post_preload [:author, :categories]

  defmodule FeaturedLevel do
    defstruct [:level, :fetch_limit]
  end

  defmodule FeaturedCachedPosts do
    use Ecto.Schema
    schema "featured_cached_posts" do
      field(:level, :integer)
      field(:post_id, :integer)
    end
  end

  def get_featured_levels(:fetcheable) do
    [_|fetcheable] = get_featured_levels()
    fetcheable
  end

  def no_featured_level, do: Enum.at(get_featured_levels(), 0)
  def get_featured_levels() do
    [
      %FeaturedLevel{level: 0, fetch_limit: :no_fetch},
      %FeaturedLevel{level: 1, fetch_limit: 1},
      %FeaturedLevel{level: 2, fetch_limit: 2},
      %FeaturedLevel{level: 3, fetch_limit: 4},
      %FeaturedLevel{level: 4, fetch_limit: 8}
    ]
  end

  def invalidate_cache do
    Multi.new
    |> clear_all_stored_cached_posts_entries
    |> Repo.transaction
  end

  def get_posts_from_level_pair(level, [{%FeaturedLevel{level: level}, posts} | _]), do: posts
  def get_posts_from_level_pair(level, [{_, _} | moreFeatured]), do: get_posts_from_level_pair(level, moreFeatured)
  def get_posts_from_level_pair(_,_), do: []

  def get_featured_posts(%FeaturedLevel{fetch_limit: :no_fetch}, _), do: []
  def get_featured_posts(%FeaturedLevel{level: level, fetch_limit: limit}, site_id) do
    posts_query = from p in Post,
      where: p.featured_level == ^level and p.site_id == ^site_id,
      order_by: [desc: p.inserted_at],
      limit: ^limit,
      preload: ^@default_post_preload
    Repo.all(posts_query)
  end

  def get_all_featured_posts(site_id) do
    Enum.map(get_featured_levels(:fetcheable), fn (level) ->
      {level, get_featured_posts(level, site_id)}
    end)
  end

  def get_all_featured_posts_ensure_filled(site_id, additive_limit) do
    featured_posts = get_all_featured_posts(site_id)
    aditional_posts = get_more_posts_from_featured(featured_posts, additive_limit, site_id)
    fill_featured_with_aditional(featured_posts, aditional_posts)
  end

  def get_all_featured_posts_ensure_filled_cached(site_id, additive_limit \\ 0) do
    cached_posts = read_all_stored_cached_posts()
    case is_featured_list_empty(cached_posts) do
      true -> 
        all_posts = get_all_featured_posts_ensure_filled(site_id, additive_limit)
        generate_and_save_featured_cached_posts_entries(all_posts)
        all_posts
      false ->
        cached_posts
    end
  end

  defp is_featured_list_empty({_, [_|_]}), do: false
  defp is_featured_list_empty({featured_list,_}), do: is_featured_list_empty(featured_list)
  defp is_featured_list_empty([{_, [ _|_]} | _]), do: false
  defp is_featured_list_empty([]), do: true
  defp is_featured_list_empty([{_, []} | rest]), do: is_featured_list_empty(rest)

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
      preload: ^@default_post_preload
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

  defp generate_featured_cached_posts_entries({featured_posts, aditional}) do
    all = [{no_featured_level(), aditional} | featured_posts]
    generate_featured_cached_posts_entries(all, [])
  end
  defp generate_featured_cached_posts_entries([{%FeaturedLevel{level: level}, posts} | featured_posts], acc) do
    posts_for_level = generate_featured_cached_posts_entries(level, posts, acc)
    generate_featured_cached_posts_entries(featured_posts, posts_for_level)
  end
  defp generate_featured_cached_posts_entries([], acc), do: acc
  defp generate_featured_cached_posts_entries(level, [post | more_posts], acc) do
    acc = [%FeaturedCachedPosts{level: level, post_id: post.id} | acc]
    generate_featured_cached_posts_entries(level, more_posts, acc)
  end
  defp generate_featured_cached_posts_entries(_level, [], acc), do: acc

  defp save_cached_posts_entries(cached_posts_entries) do
    {:ok, _} = Multi.new
    |> clear_all_stored_cached_posts_entries()
    |> insert_all_featured_cached_posts_entries(cached_posts_entries)
    |> Repo.transaction
  end

  def insert_all_featured_cached_posts_entries(multi, [entry | entries]) do
    Multi.insert(multi, "cache_entry_#{entry.post_id}", entry)
    |> insert_all_featured_cached_posts_entries(entries)
  end
  def insert_all_featured_cached_posts_entries(multi, []), do: multi

  defp generate_and_save_featured_cached_posts_entries(featured_posts) do
    cache_entries = generate_featured_cached_posts_entries(featured_posts)
    save_cached_posts_entries(cache_entries)
  end

  defp clear_all_stored_cached_posts_entries(multi) do
    delete_query = from _ in FeaturedCachedPosts, where: true
    Multi.delete_all(multi, :clear_all_cache_entries, delete_query)
  end

  def read_all_stored_cached_posts() do
    cached_posts_list = read_all_stored_cached_posts_from_db()
    {featured_posts, aditional_posts} = get_posts_from_list_with_level(cached_posts_list)
    fill_featured_with_aditional(featured_posts, aditional_posts)
  end

  defp get_posts_from_list(featured_level, posts), do: get_posts_from_list(featured_level, posts, [], [])
  defp get_posts_from_list(%FeaturedLevel{fetch_limit: limit}, posts, rem, result) when
    limit >= length(result) or limit == :no_fetch, do: 
    {result, Enum.reverse(rem) ++ posts}
  defp get_posts_from_list(%FeaturedLevel{level: level} = featured_level, [post | posts], rem, result) do
    if level == post.featured_level do
      get_posts_from_list(featured_level, posts, rem, [post | result])
    else
      get_posts_from_list(featured_level, posts, [post | rem], [post | result])
    end
  end

  defp get_posts_from_list_with_level(cached_posts) do
    Enum.reduce(get_featured_levels(:fetcheable), {[], cached_posts}, 
    fn(featured_level, {result, remainding}) ->
      {posts_of_level, remainding} = get_posts_from_list(featured_level, remainding)
      {[{featured_level, posts_of_level} | result], remainding}
    end)
  end

  def read_all_stored_cached_posts_from_db() do
    posts = from post in Post,
      join: cache in FeaturedCachedPosts,
      on: cache.id == post.id,
      order_by: [desc: post.inserted_at],
      preload: ^@default_post_preload
    Repo.all(posts)
  end

end
