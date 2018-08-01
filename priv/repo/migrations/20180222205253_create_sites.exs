defmodule ElephantInTheRoom.Repo.Migrations.CreateSites do
  use Ecto.Migration

  def change do
    create table(:sites) do
      add(:name, :string)
      add(:host, :string)
      add(:description, :string)
      add(:image, :string)
      add(:favicon, :string)
      add(:title, :string)
      timestamps()
    end

    create(unique_index(:sites, [:host]))
    create(unique_index(:sites, [:name]))
  end
end
