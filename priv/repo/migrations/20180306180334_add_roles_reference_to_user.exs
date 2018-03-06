defmodule ElephantInTheRoom.Repo.Migrations.AddRolesReferenceToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add(:role_id, references(:roles), on_delete: :delete_all)
    end
  end
end
