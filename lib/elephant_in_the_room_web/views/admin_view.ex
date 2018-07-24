defmodule ElephantInTheRoomWeb.AdminView do
  use ElephantInTheRoomWeb, :view
  alias ElephantInTheRoom.Sites.{Site, Post, Tag}


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
      :tags ->
        bread_crumb_get_link(data, rest,
          [bread_crumb_tags(data.conn, data.site) | acc])
      %Tag{} = tag ->
        bread_crumb_get_link(Map.put(data, :tag, tag), rest,
          [bread_crumb_tag_edit(data.conn, data.site, tag) | acc])
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
    {"Sitios", site_path(conn, :index)}
  end

  defp bread_crumb_site(conn, %Site{name: name, id: id}) do
    {name, site_path(conn, :show, id)}
  end

  defp bread_crumb_posts(conn, %Site{id: id}) do
    {"Artículos", site_post_path(conn, :index, id)}
  end

  defp bread_crumb_post(conn,%Site{id: site_id}, %Post{id: post_id}) do
    {"#{post_id}", site_post_path(conn, :show, site_id, post_id)}
  end

  defp bread_crumb_post_edit(conn,%Site{id: site_id}, %Post{id: post_id}) do
    {"Editar", site_post_path(conn, :edit, site_id, post_id)}
  end

  defp bread_crumb_tags(conn, %Site{id: site_id}) do
    {"Etiquetas", site_tag_path(conn, :index, site_id)}
  end

  defp bread_crumb_tag_edit(_conn, _, %Tag{id: nil}) do
    {"Etiqueta",""}
  end
  defp bread_crumb_tag_edit(conn, %Site{id: site_id}, %Tag{id: tag_id, name: tag_name}) do
    {"\##{tag_name}", site_tag_path(conn, :edit, site_id, tag_id)}
  end

end
