defmodule ElephantInTheRoomWeb.BackupController do
  use ElephantInTheRoomWeb, :controller
  alias ElephantInTheRoom.{Backup, BackupData}

  def do_backup(conn, _params) do
    Backup.run_backup_now()
    redirect(conn, to: backup_path(conn, :index))
  end

  def index(conn, _params) do
    status = Backup.get_status()

    render(
      conn,
      "index.html",
      activated: status[:activated],
      will_run_at: status[:will_run_at],
      last_backup_ready_at: status[:last_backup_ready_at],
      last_backup_location: status[:last_backup_location],
      status: status[:status]
    )
  end

  def get_modify_settings(conn, _params) do
    data = BackupData.get_backup_data()
    changeset = BackupData.changeset(data)
    render(conn, "modify_settings_form.html", data: data, changeset: changeset)
  end

  def download_latest(conn, _params) do
    %{last_backup_location: location} = Backup.get_status()

    case location do
      location when is_binary(location) and location != "" ->
        start_download(conn, location)

      _ ->
        render(conn, "no_ready_to_download.html")
    end
  end

  def start_download(conn, location) do
    file_name = Path.basename(location)

    conn
    |> put_resp_header("content-disposition", ~s(attachment; filename="#{file_name}"))
    |> send_file(200, location)
  end
end
