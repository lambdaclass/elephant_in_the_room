defmodule ElephantInTheRoomWeb.FeedbackController do
  use ElephantInTheRoomWeb, :controller
  alias ElephantInTheRoom.{Sites, Sites.Feedback}

  def index(%{assigns: %{site: site}} = conn, _params) do
    feedbacks = Sites.list_feedbacks(site)
    render(conn, "index.html", feedbacks: feedbacks)
  end

  def new(%{assigns: %{site: site}} = conn, _params) do
    changeset =
      %Feedback{site_id: site.id}
      |> Sites.change_feedback()

    render(conn, "new.html", changeset: changeset)
  end

  def create(%{assigns: %{site: site}} = conn, params) do
    case Sites.create_feedback(site, params) do
      {:ok, _feedback} ->
        conn
        |> put_flash(:info, "Feedback creado satisfactoriamente.")
        |> redirect(to: site_path(conn, :public_show))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, site: site)
    end
  end
end
