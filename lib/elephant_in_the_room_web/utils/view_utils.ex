defmodule ElephantInTheRoomWeb.Utils.ViewUtils do

  def compare(1, 1), do: :unique_page

  def compare(x, x), do: :equal

  def compare(1, _y), do: :first

  def compare(x, y) when x > y, do: :greater

  def compare(x, y) when x < y, do: :lesser

  def page_pagination_check(page_number, total_pages) do
    show_left = page_number > 1
    show_right = total_pages > 1 && page_number < total_pages
    show_middle = show_left && show_right
    {show_left, show_middle, show_right}
  end
end
