defmodule ElephantInTheRoomWeb.FeedbackController do
  use ElephantInTheRoomWeb, :controller
  plug(:put_layout, false when action == :create)
  alias ElephantInTheRoom.{Repo, Sites, Sites.Feedback, Sites.Site}
  import Ecto.Query

  def index(%{assigns: %{site: site}} = conn, params) do
    feedbacks =
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
      feedbacks: feedbacks,
      site: site,
      bread_crumb: [:sites, site, :feedbacks]
    )
  end

  def create(%{assigns: %{site: site}} = conn, params) do
    case Sites.create_feedback(site, params) do
      {:ok, _feedback} ->
        conn
        |> put_flash(:feedback_ok, "Feedback creado satisfactoriamente.")
        |> render("feedback_form.html")

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_errors(changeset)
        |> render("feedback_form.html", changeset: changeset)
    end
  end

  def show(conn, %{"site_name" => site_name, "id" => id}) do
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
