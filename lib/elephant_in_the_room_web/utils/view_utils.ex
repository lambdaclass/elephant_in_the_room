defmodule ElephantInTheRoomWeb.Utils.ViewUtils do
  def compare(x, x) do
    :equal
  end

  def compare(1, y) do
    :first
  end

  def compare(x, y) when x > y do
    :greater
  end

  def compare(x, y) when x < y do
    :lesser
  end
end
