defmodule ElephantInTheRoom.Repo.Migrations.CreateCategories do
  use Ecto.Migration

  def change do
    create table(:categories) do
      add(:name, :string)
      add(:description, :string)
      add(:site_id, references(:sites))

      timestamps()
    end
  end
end
