defmodule ElephantInTheRoom.Repo.Migrations.CreateTags do
  use Ecto.Migration

  def change do
    create table(:tags) do
      add(:name, :string)
      add(:site_id, references(:sites, on_delete: :delete_all))

      timestamps()
    end

    create(index(:tags, [:site_id]))
  end
end
