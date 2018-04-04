defmodule ElephantInTheRoomWeb.PaginationView do
  use ElephantInTheRoomWeb, :view
  def compare(1, 1), do: :unique_page

  def compare(x, x), do: :equal

  def compare(1, y), do: :first

  def compare(x, y) when x > y, do: :greater

  def compare(x, y) when x < y, do: :lesser

  def paginate(conn, page_number, total_pages, path_function, site) do
    render(
      "_pagination.html",
      conn: conn,
      page_number: page_number,
      total_pages: total_pages,
      path_function: path_function,
      site: site
    )
  end

  def paginate(conn, page_number, total_pages, path_function) do
    render(
      "_pagination.html",
      conn: conn,
      page_number: page_number,
      total_pages: total_pages,
      path_function: path_function
    )
  end
end
