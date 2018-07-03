defmodule ElephantInTheRoom.BackupData do
  use Ecto.Schema
  import Ecto.Changeset
  alias ElephantInTheRoom.BackupData

  schema "backup_data" do
    field :enabled, :boolean
    field :start_time, :time
    field :interval, :integer
    field :last_backup_name, :string
    field :last_backup_moment, :utc_datetime
  end

  @doc false
  def changeset(%BackupData{} = author, attrs) do
    author
    |> cast(attrs, [:enabled, :interval, :last_backup_name, :last_backup_moment])
    |> validate_required([:enabled, :interval])
  end
  def changeset(author), do: changeset(author, %{})

  def get_backup_data do
    Repo.get!(BackupData, 1)
  end

end