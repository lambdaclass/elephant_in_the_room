defmodule ElephantInTheRoom.Repo.Migrations.CreateTags do
  use Ecto.Migration

  def change do
    create table(:tags) do
      add(:name, :string)
      add(:color, :string)
      add(:site_id, references(:sites, on_delete: :delete_all, type: :uuid))

      timestamps()
    end

    create(index(:tags, [:site_id]))
  end
end
