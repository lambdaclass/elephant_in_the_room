defmodule ElephantInTheRoom.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:username, :string)
      add(:firstname, :string)
      add(:lastname, :string)
      add(:email, :string)
      add(:password, :string)
      add(:role_id, references(:roles, type: :uuid), on_delete: :delete_all)

      timestamps()
    end

    create(unique_index(:users, [:username]))
    create(unique_index(:users, [:email]))
  end
end
