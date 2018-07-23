defmodule ElephantInTheRoomWeb.Utils.Utils do
  alias ElephantInTheRoom.Sites.Site
  alias Plug.Conn

  def get_env(where, name) do
    conf = Application.get_env(:elephant_in_the_room, where)
    value = Keyword.get(conf, name)

    case value do
      nil -> raise "no variable #{where}.#{name} defined in configuration"
      value -> value
    end
  end

  def generate_absolute_url(relative_path, conn), do:
    absolute_url_str(conn, conn.assigns.site.host, relative_path)

  def generate_absolute_url(relative_path, conn, %Site{host: host}), do:
    absolute_url_str(conn, host, relative_path)

  defp absolute_url_str(%Conn{scheme: scheme} = conn, domain, relative_path) do
    port = get_port(conn)
    "#{scheme}://#{domain}#{port}#{relative_path}"
  end

  defp get_port(%Conn{scheme: scheme, port: port}) do
    case {scheme, port} do
      {"http", 80} -> ""
      {"https", 443} -> ""
      {_, port} -> ":#{port}"
    end
  end

  def complete_zeros(:date, date) do
    complete = fn n ->
      if String.length(n) == 1, do: "0" <> n, else: n
    end

    year = complete.("#{date.year}")
    month = complete.("#{date.month}")
    day = complete.("#{date.day}")

    "#{year}-#{month}-#{day}"
  end

  def complete_zeros(:hour, date) do
    complete = fn n ->
      if String.length(n) == 1, do: "0" <> n, else: n
    end

    hour = complete.("#{date.hour}")
    minute = complete.("#{date.minute}")
    second = complete.("#{date.second}")

    %{hour: hour, minute: minute, second: second}
  end
end
