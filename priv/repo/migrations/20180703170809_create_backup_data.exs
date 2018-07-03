defmodule ElephantInTheRoom.Repo.Migrations.CreateBackupData do
  use Ecto.Migration

  def change do
    create table(:backup_data) do
      add :last_backup_name, :string
      add :last_backup_moment, :utc_datetime
    end
  end
end
