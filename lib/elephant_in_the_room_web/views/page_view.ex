defmodule ElephantInTheRoomWeb.PageView do
  use ElephantInTheRoomWeb, :view

  alias ElephantInTheRoom.Sites

  def get_sites do
    Sites.list_sites()
  end

  def get_categories(site, number_of_categories \\ 3) do
    site.categories
    |> Enum.take(number_of_categories)
    |> Enum.map(fn cat -> cat.name end)
  end
end
