defmodule ElephantInTheRoomWeb.FeedbackController do
  use ElephantInTheRoomWeb, :controller
  alias ElephantInTheRoom.{Repo, Sites, Sites.Feedback}
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
      total_entries: page.total_entries
    )
  end

  def create(%{assigns: %{site: site}} = conn, params) do
    case Sites.create_feedback(site, params) do
      {:ok, _feedback} ->
        conn
        |> put_flash(:feedback_ok, "Feedback creado satisfactoriamente.")
        |> redirect(to: site_path(conn, :public_show))

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_errors(changeset)
        |> redirect(to: site_path(conn, :public_show))
    end
  end

  def show(conn, %{"site_name" => site_name, "feedback_id" => id}) do
    feedback_site = Sites.from_name!(site_name, Site)
    feedback = Sites.get_feedback!(feedback_site, id)
    render(conn, "show.html", feedback: feedback, site: feedback_site)
  end

  defp put_errors(conn, changeset) do
    changeset.errors
    |> Enum.map(fn {k, v} -> {k, elem(v, 0)} end)
    |> Enum.reduce(conn, fn {_k, err}, connection ->
      put_flash(connection, :feedback_error, "Error: #{err}")
    end)
  end
end
