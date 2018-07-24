defmodule ElephantInTheRoom.BackupData do
  use Ecto.Schema
  import Ecto.Changeset
  alias ElephantInTheRoom.BackupData
  alias ElephantInTheRoom.Repo

  @uuid "f99264db-9df1-47cd-8942-701c31e03d0c"

  @primary_key {:id, :binary_id, autogenerate: true}
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
    case Repo.get(BackupData, @uuid) do
      nil ->
        default = %BackupData{id: @uuid}
        Repo.insert_or_update!(changeset(default))
        default
      r -> r
    end
  end

  def store_back_data(%BackupData{} = data) do
    Repo.update!(changeset(%{data | id: @uuid}))
  end

end
