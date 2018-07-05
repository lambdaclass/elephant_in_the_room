defmodule ElephantInTheRoom.BackupData do
  use Ecto.Schema
  import Ecto.Changeset
  alias ElephantInTheRoom.BackupData
  alias ElephantInTheRoom.Repo

  schema "backup_data" do
    field :last_backup_name, :string
    field :last_backup_moment, :utc_datetime
  end

  @doc false
  def changeset(%BackupData{} = author, attrs) do
    author
    |> cast(attrs, [:last_backup_name, :last_backup_moment])
  end
  def changeset(author), do: changeset(author, %{})

  def get_backup_data do
    case Repo.get(BackupData, 1) do
      nil -> 
        default = %BackupData{id: 1}
        Repo.insert_or_update!(changeset(default))
        default
      r -> r
    end
  end

  def store_back_data(%BackupData{} = data) do
    Repo.update!(changeset(%{data | id: 1}))
  end

end