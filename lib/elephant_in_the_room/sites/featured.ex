defmodule ElephantInTheRoom.Sites.Featured do
  import Ecto.Query, warn: false
  alias ElephantInTheRoom.Sites.Post
  alias ElephantInTheRoom.Repo

  defmodule FeaturedLevel do
    defstruct [:level, :limit]
  end

  def get_featured_levels() do
    [
      %FeaturedLevel{level: 0, limit: :no_fetch},
      %FeaturedLevel{level: 1, limit: 1},
      %FeaturedLevel{level: 2, limit: 2},
      %FeaturedLevel{level: 3, limit: 4},
      %FeaturedLevel{level: 4, limit: 8}
    ]
  end

  def get_featured_posts(%FeaturedLevel{limit: :no_fetch}), do: []
  def get_featured_posts(%FeaturedLevel{level: level, limit: limit}) do
    posts_query = from p in Post,
      where: p.featured_level == ^level,
      order_by: [desc: p.inserted_at],
      limit: ^limit,
      preload: [:author]
    Repo.all(posts_query)
  end

  def get_all_featured_posts() do
    Enum.map(get_featured_levels(), fn (level) ->
      {level, get_featured_posts(level)}
    end)
  end

end
