defmodule ElephantInTheRoomWeb.Utils.ViewUtils do
  def compare(1, 1), do: :unique_page

  def compare(x, x), do: :equal

  def compare(1, y), do: :first

  def compare(x, y) when x > y, do: :greater

  def compare(x, y) when x < y, do: :lesser
end
