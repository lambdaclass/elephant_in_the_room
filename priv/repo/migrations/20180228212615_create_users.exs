defmodule ElephantInTheRoom.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add(:username, :string)
      add(:firstname, :string)
      add(:lastname, :string)
      add(:email, :string)
      add(:password, :string)

      timestamps()
    end

    create(unique_index(:users, [:username]))
    create(unique_index(:users, [:email]))
  end
end
