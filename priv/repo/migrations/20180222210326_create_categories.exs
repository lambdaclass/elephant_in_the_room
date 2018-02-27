defmodule ElephantInTheRoom.Repo.Migrations.CreateCategories do
  use Ecto.Migration

  def change do
    create table(:categories) do
      add(:name, :string)
      add(:description, :string)
      add(:site_id, references(:sites, on_delete: :delete_all))

      timestamps()
    end

    create(unique_index(:categories, [:name]))
    create(index(:categories, [:site_id]))
  end
end
