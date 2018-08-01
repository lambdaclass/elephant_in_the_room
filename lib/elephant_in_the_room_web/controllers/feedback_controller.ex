defmodule ElephantInTheRoomWeb.FeedbackController do
  use ElephantInTheRoomWeb, :controller
  alias ElephantInTheRoom.{Sites}

  def index(%{assigns: %{site: site}} = conn, _params) do
    feedbacks = Sites.list_feedbacks(site)
    render(conn, "index.html", feedbacks: feedbacks)
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




  defp put_errors(conn, changeset) do
    changeset.errors
    |> Enum.map(fn {k, v} -> {k, (elem(v, 0))} end)
    |> Enum.reduce(conn, fn ({_k, err}, connection) -> put_flash(connection, :feedback_error, "Error: #{err}") end)
  end
end
