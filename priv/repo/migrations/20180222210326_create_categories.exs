defmodule ElephantInTheRoom.Repo.Migrations.CreateCategories do
  use Ecto.Migration

  def change do
    create table(:categories, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:name, :string)
      add(:description, :string)
      add(:site_id, references(:sites, on_delete: :delete_all, type: :uuid))

      timestamps()
    end

    create(unique_index(:categories, [:name]))
    create(index(:categories, [:site_id]))
  end
end
