defmodule ElephantInTheRoom.Sites.Featured do
  defmodule FeaturedLevel do
    defstruct [:level, :limit]
  end

  def get_featured_levels do
    [
      %FeaturedLevel{level: 0, limit: :no_limit},
      %FeaturedLevel{level: 1, limit: 1},
      %FeaturedLevel{level: 2, limit: 2},
      %FeaturedLevel{level: 3, limit: 4},
      %FeaturedLevel{level: 4, limit: 8}
    ]
  end

end
