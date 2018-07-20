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

    port =
      case {scheme, conn.port} do
        {"http", 80} -> ""
        {"https", 443} -> ""
        {_, port} -> ":#{port}"
      end

    "#{scheme}://#{conn.assigns.site.host}#{port}#{relative_path}"
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


  def get_page(%{"page" => page}), do: String.to_integer(page)
  def get_page(_), do: 1

end
