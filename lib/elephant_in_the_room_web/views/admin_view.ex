defmodule ElephantInTheRoomWeb.AdminView do
  use ElephantInTheRoomWeb, :view
  alias ElephantInTheRoom.Posts.{Post, Tag}
  alias ElephantInTheRoom.Sites.{Ad, Magazine, Site}

  def bread_crumb(conn, path) when is_list(path) do
    bread_crumb_get_link(conn, path)
  end

  def bread_crumb(conn, _), do: bread_crumb_get_link(conn, [])

  def bread_crumb_get_link(conn, path) do
    bread_crumb_get_link(%{conn: conn}, path, [])
  end

  def bread_crumb_get_link(data, [:sites | rest], acc) do
    bread_crumb_get_link(data, rest, [bread_crumb_sites(data.conn) | acc])
  end

  def bread_crumb_get_link(data, [:roles | rest], acc) do
    bread_crumb_get_link(data, rest, [bread_crumb_roles(data.conn) | acc])
  end

  def bread_crumb_get_link(data, [:authors | rest], acc) do
    bread_crumb_get_link(data, rest, [bread_crumb_authors(data.conn) | acc])
  end

  def bread_crumb_get_link(data, [:feedbacks | rest], acc) do
    bread_crumb_get_link(data, rest, [bread_crumb_feedbacks(data.conn, data.site) | acc])
  end

  def bread_crumb_get_link(data, [:users | rest], acc) do
    bread_crumb_get_link(data, rest, [bread_crumb_users(data.conn) | acc])
  end

  def bread_crumb_get_link(data, [:posts | rest], acc) do
    bread_crumb_get_link(data, rest, [bread_crumb_posts(data.conn, data.site) | acc])
  end

  def bread_crumb_get_link(data, [:post_edit | rest], acc) do
    bread_crumb_get_link(data, rest, [bread_crumb_post_edit(data.conn, data.site, data.post) | acc])
  end

  def bread_crumb_get_link(data, [:tags | rest], acc) do
    bread_crumb_get_link(data, rest, [bread_crumb_tags(data.conn, data.site) | acc])
  end

  def bread_crumb_get_link(data, [:ads | rest], acc) do
    bread_crumb_get_link(data, rest, [bread_crumb_ads(data.conn, data.site) | acc])
  end

  def bread_crumb_get_link(data, [:magazines | rest], acc) do
    bread_crumb_get_link(data, rest, [bread_crumb_magazines(data.conn, data.site) | acc])
  end

  def bread_crumb_get_link(data, [%Site{} = site | rest], acc) do
    bread_crumb_get_link(Map.put(data, :site, site), rest, [
      bread_crumb_site(data.conn, site) | acc
    ])
  end

  def bread_crumb_get_link(data, [%Post{} = post | rest], acc) do
    bread_crumb_get_link(Map.put(data, :post, post), rest, [
      bread_crumb_post(data.conn, data.site, post) | acc
    ])
  end

  def bread_crumb_get_link(data, [%Tag{} = tag | rest], acc) do
    bread_crumb_get_link(Map.put(data, :tag, tag), rest, [
      bread_crumb_tag_edit(data.conn, data.site, tag) | acc
    ])
  end

  def bread_crumb_get_link(data, [%Ad{} = ad | rest], acc) do
    bread_crumb_get_link(Map.put(data, :ad, ad), rest, [
      bread_crumb_ads(data.conn, data.site, ad) | acc
    ])
  end

  def bread_crumb_get_link(data, [%Magazine{} = magazine | rest], acc) do
    bread_crumb_get_link(data, rest, [
      bread_crumb_magazines(data.conn, data.site, magazine) | acc
    ])
  end

  def bread_crumb_get_link(data, [action | rest], acc) do
    bread_crumb_get_link(data, rest, [{bread_crumb_action(action), "#"} | acc])
  end

  def bread_crumb_get_link(_, [], acc) do
    case acc do
      [] -> {[], []}
      [x] -> {[], x}
      [h | t] -> {Enum.reverse(t), h}
    end
  end

  defp bread_crumb_sites(conn), do: {"Sitios", site_path(conn, :index)}

  defp bread_crumb_site(conn, %Site{name: name}), do: {name, site_path(conn, :show, name)}

  defp bread_crumb_authors(conn) do
    {"Autores", author_path(conn, :index)}
  end

  defp bread_crumb_roles(conn) do
    {"Roles", role_path(conn, :index)}
  end

  defp bread_crumb_users(conn) do
    {"Usuarios", user_path(conn, :index)}
  end

  defp bread_crumb_feedbacks(conn, %Site{name: site_name}) do
    {"Sugerencias", site_feedback_path(conn, :index, URI.encode(site_name))}
  end

  defp bread_crumb_posts(conn, %Site{name: site_name}),
    do: {"Artículos", site_post_path(conn, :index, site_name)}

  defp bread_crumb_post(conn, _site, %Post{inserted_at: date, title: title} = post) do
    {"#{title}", post_path(conn, :public_show, date.year, date.month, date.day, post.slug)}
  end

  defp bread_crumb_post_edit(conn, %Site{id: site_id}, %Post{id: post_id}) do
    {"Editar", site_post_path(conn, :edit, site_id, post_id)}
  end

  defp bread_crumb_tags(conn, %Site{name: site_name}) do
    {"Etiquetas", site_tag_path(conn, :index, URI.encode(site_name))}
  end

  defp bread_crumb_tag_edit(_conn, _, %Tag{id: nil}), do: {"Etiqueta", ""}

  defp bread_crumb_tag_edit(conn, %Site{name: site_name}, %Tag{name: tag_name}) do
    {"\##{tag_name}", site_tag_path(conn, :edit, URI.encode(site_name), URI.encode(tag_name))}
  end

  defp bread_crumb_ads(conn, %Site{name: site_name}) do
    {"Promociones", site_ad_path(conn, :index, URI.encode(site_name))}
  end

  defp bread_crumb_ads(conn, %Site{name: site_name}, %Ad{name: ad_name}) do
    {ad_name, site_ad_path(conn, :edit, URI.encode(site_name), URI.encode(ad_name))}
  end

  defp bread_crumb_magazines(conn, %Site{name: site_name}) do
    {"Revistas", site_magazine_path(conn, :index, URI.encode(site_name))}
  end

  defp bread_crumb_magazines(conn, %Site{name: site_name}, %Magazine{title: magazine_title}) do
    {magazine_title, site_magazine_path(conn, :index, URI.encode(site_name))}
  end

  defp bread_crumb_action(:new), do: "Nuevo"
  defp bread_crumb_action(:root), do: ""
  defp bread_crumb_action(_), do: "Undefined Action"
end
