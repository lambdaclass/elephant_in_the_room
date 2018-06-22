defmodule ElephantInTheRoomWeb.Utils.Utils do

  def get_env(where, name) do
    conf = Application.get_env(:elephant_in_the_room, where)
    value = Keyword.get(conf, name)
    case value do
      nil -> raise "no variable #{where}.#{name} defined in configuration"
      value -> value
    end
  end

end
