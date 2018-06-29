defmodule ElephantInTheRoomWeb.AdminView do
  use ElephantInTheRoomWeb, :view
  alias ElephantInTheRoom.Sites.{Site, Post}


  def bread_crumb(conn, path) when is_list(path) do
    bread_crumb_get_link(conn, path)
  end
  def bread_crumb(conn, _) do
    bread_crumb_get_link(conn, [])
  end

  def bread_crumb_get_link(conn, path) do
    bread_crumb_get_link(%{conn: conn}, path, [])
  end
  def bread_crumb_get_link(data, [element | rest], acc) do
    case element do
      :sites ->
        bread_crumb_get_link(data, rest,
          [bread_crumb_sites(data.conn) | acc])
      %Site{} = site ->
        bread_crumb_get_link(Map.put(data, :site, site), rest,
          [bread_crumb_site(data.conn, site) | acc])
      :posts ->
        bread_crumb_get_link(data, rest,
          [bread_crumb_posts(data.conn,  data.site) | acc])
      %Post{} = post ->
        bread_crumb_get_link(Map.put(data, :post, post), rest,
          [bread_crumb_post(data.conn, data.site, post) | acc])
      :post_edit ->
        bread_crumb_get_link(data, rest,
          [bread_crumb_post_edit(data.conn, data.site, data.post) | acc])
      _ ->
        bread_crumb_get_link(data, rest, acc)
    end
  end
  def bread_crumb_get_link(_, [], acc) do
    case acc do
      [] -> {[], []}
      [x] -> {[], x}
      [h | t] -> {Enum.reverse(t), h}
    end
  end


  defp bread_crumb_sites(conn) do
    {"Sites", site_path(conn, :index)}
  end

  defp bread_crumb_site(conn, %Site{name: name, id: id}) do
    {name, site_path(conn, :show, id)}
  end

  defp bread_crumb_posts(conn,%Site{name: name, id: id}) do
    {"Posts", site_post_path(conn, :index, id)}
  end

  defp bread_crumb_post(conn,%Site{id: site_id}, %Post{id: post_id}) do
    {"#{post_id}", site_post_path(conn, :show, site_id, post_id)}
  end

  defp bread_crumb_post_edit(conn,%Site{id: site_id}, %Post{id: post_id}) do
    {"Edit", site_post_path(conn, :edit, site_id, post_id)}
  end

end
