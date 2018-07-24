defmodule ElephantInTheRoom.Repo.Migrations.CreateSites do
  use Ecto.Migration

  def change do
    create table(:sites, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:name, :string)
      add(:host, :string)
      timestamps()
    end

    create(unique_index(:sites, [:host]))
    create(unique_index(:sites, [:name]))
  end
end
