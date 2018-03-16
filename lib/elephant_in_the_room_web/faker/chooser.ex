defmodule ElephantInTheRoomWeb.Faker.Chooser do
  def choose_one(list) do
    random_index = list |> length |> :rand.uniform()

    list |> Enum.at(random_index - 1)
  end

  def choose_n(max_number, list) do
    set = MapSet.new()
    len = length(list)
    n = :rand.uniform(max_number)

    set = accum(n, set, fn -> Enum.at(list, :rand.uniform(len - 1)) end)

    MapSet.to_list(set)
  end

  defp accum(0, set, fun) do
    MapSet.put(set, fun.())
  end

  defp accum(n, set, fun) when n > 0 do
    new_set = accum(n - 1, set, fun)
    MapSet.put(new_set, fun.())
  end
end
