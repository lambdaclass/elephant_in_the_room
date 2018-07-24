defmodule ElephantInTheRoom.Repo.Migrations.CreateMagazines do
  use Ecto.Migration

  def change do
    create table(:magazines) do
      add :title, :string
      add :cover, :string
      add :description, :text
      add :site_id, references(:sites, on_delete: :delete_all)

      timestamps()
    end

    create(index(:magazines, [:site_id]))

    alter table(:posts) do
      add :magazine_id, references(:magazines, on_delete: :delete_all)
    end

    create(index(:posts, [:magazine_id]))
  end
end
