defmodule ElephantInTheRoomWeb.BackupController do
  use ElephantInTheRoomWeb, :controller
  alias ElephantInTheRoom.Backup
  alias ElephantInTheRoom.BackupData
  alias ElephantInTheRoom.Repo


  def index(conn, %{"run_backup_now"  => "true"}) do
    Backup.run_backup_now()
    redirect conn, to: backup_path(conn, :index)
  end

  def index(conn, _params) do 
    status = Backup.get_status()
    render(conn, "index.html",
      activated: status[:activated],
      will_run_at: status[:will_run_at],
      status: status[:status])
  end

  def get_modify_settings(conn, _params) do
    data = BackupData.get_backup_data()
    changeset = BackupData.changeset(data)
    render(conn, "modify_settings_form.html", data: data, changeset: changeset)
  end

end