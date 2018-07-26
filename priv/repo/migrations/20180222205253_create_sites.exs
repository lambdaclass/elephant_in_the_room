defmodule ElephantInTheRoom.Repo.Migrations.CreateSites do
  use Ecto.Migration

  def change do
    create table(:sites) do
      add(:name, :string)
      add(:host, :string)
      timestamps()
    end

    create(unique_index(:sites, [:host]))
    create(unique_index(:sites, [:name]))
  end
end
