defmodule ElephantInTheRoom.Repo.Migrations.CreateImages do
  use Ecto.Migration

  def change do
    create table(:images, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:binary, :binary)

      timestamps()
    end
  end
end
