defmodule ElephantInTheRoomWeb.Utils.Utils do

  def get_env(where, name) do
    conf = Application.get_env(:elephant_in_the_room, where)
    value = Keyword.get(conf, name)
    case value do
      nil -> raise "no variable #{where}.#{name} defined in configuration"
      value -> value
    end
  end

  def generate_absolute_url(relative_path, conn) do
    scheme = to_string(conn.scheme)
    port = case {scheme, conn.port} do
      {"http",  80}  -> ""
      {"https", 443} -> ""
      {_, port} -> ":#{port}"
    end
    "#{scheme}://#{conn.assigns.site.host}#{port}#{relative_path}"
  end

end
