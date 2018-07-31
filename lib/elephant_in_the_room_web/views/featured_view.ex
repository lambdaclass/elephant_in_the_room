defmodule ElephantInTheRoomWeb.FeaturedView do
  use ElephantInTheRoomWeb, :view
  alias ElephantInTheRoom.Sites.Featured
  alias ElephantInTheRoom.Sites.Featured.FeaturedLevel

  def get_available_featured_levels do
    Featured.get_featured_levels()|> Enum.map(fn featured_level ->
      {get_featured_level_name(featured_level),
       get_featured_level_id(featured_level)}
    end)
  end

  defp get_featured_level_id(%FeaturedLevel{level: id}), do: id
  defp get_featured_level_name(%FeaturedLevel{level: 0}), do: "Sin destacar"
  defp get_featured_level_name(%FeaturedLevel{level: 1}), do: "Tapa"
  defp get_featured_level_name(%FeaturedLevel{level: 2}), do: "Primeros destacados"
  defp get_featured_level_name(%FeaturedLevel{level: 3}), do: "Segundos destacados"
  defp get_featured_level_name(%FeaturedLevel{level: 4}), do: "Importantes"

end
