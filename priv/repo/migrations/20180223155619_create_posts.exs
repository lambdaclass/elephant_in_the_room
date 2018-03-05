defmodule ElephantInTheRoom.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add(:title, :string)
      add(:content, :string)
      add(:rendered_content, :string)
      add(:image, :string)
      add(:site_id, references(:sites, on_replace: :delete, on_delete: :delete_all))

      timestamps()
    end

    create(unique_index(:posts, [:title]))
    create(index(:posts, [:site_id]))
  end
end
