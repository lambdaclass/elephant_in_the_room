defmodule ElephantInTheRoom.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add(:username, :string)
      add(:firstname, :string)
      add(:lastname, :string)
      add(:email, :string)
      add(:password, :string)
      add(:role_id, references(:roles, on_delete: :delete_all, type: :uuid))

      timestamps()
    end

    create(unique_index(:users, [:username]))
    create(unique_index(:users, [:email]))
  end
end
