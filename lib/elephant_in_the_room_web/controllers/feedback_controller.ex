defmodule ElephantInTheRoomWeb.FeedbackController do
  use ElephantInTheRoomWeb, :controller
  alias ElephantInTheRoom.{Repo, Sites, Sites.Feedback, Sites.Site}
  import Ecto.Query

  def index(%{assigns: %{site: site}} = conn, params) do
    page =
      case params do
        %{"page" => page_number} ->
          Feedback
          |> where([f], f.site_id == ^site.id)
          |> Repo.paginate(page: page_number)

        %{} ->
          Feedback
          |> where([c], c.site_id == ^site.id)
          |> Repo.paginate(page: 1)
      end

    render(
      conn,
      "index.html",
      feedbacks: page.entries,
      site: site,
      page_number: page.page_number,
      page_size: page.page_size,
      total_pages: page.total_pages,
      total_entries: page.total_entries,
      bread_crumb: [:sites, site, :feedbacks]
    )
  end

  def create(%{assigns: %{site: site}} = conn, params) do
    case Sites.create_feedback(site, params) do
      {:ok, _feedback} ->
        conn
        |> put_resp_content_type("application/json")
        |> resp(200, Poison.encode!("Feedback creado satisfactoriamente."))
        |> send_resp()

      {:error, %Ecto.Changeset{} = changeset} ->
        conn_with_errors = put_errors(conn, changeset)
        errors = get_flash(conn_with_errors, :feedback_error)

        conn_with_errors
        |> put_resp_content_type("application/json")
        |> resp(422, Poison.encode!(errors))
        |> send_resp()
    end
  end

  def show(conn, %{"site_name" => site_name, "feedback_id" => id}) do
    feedback_site = Sites.from_name!(site_name, Site)
    feedback = Sites.get_feedback!(feedback_site, id)
    render(conn, "show.html", feedback: feedback, site: feedback_site)
  end

  def delete(conn, %{"site_name" => site_name, "id" => id}) do
    feedback_site = Sites.from_name!(site_name, Site)
    feedback = Sites.get_feedback!(feedback_site, id)
    {:ok, _feedback} = Sites.delete_feedback(feedback)

    conn
    |> redirect(to: site_feedback_path(conn, :index, site_name))
  end

  defp put_errors(conn, changeset) do
    changeset.errors
    |> Enum.map(fn {k, v} -> {k, elem(v, 0)} end)
    |> Enum.reduce(conn, fn {_k, err}, connection ->
      put_flash(connection, :feedback_error, "Error: #{err}")
    end)
  end
end
