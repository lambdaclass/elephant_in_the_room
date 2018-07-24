defmodule ElephantInTheRoom.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:title, :string)
      add(:slug, :string)
      add(:abstract, :text)
      add(:content, :text)
      add(:rendered_content, :text)
      add(:image, :text)
      add(:site_id, references(:sites, on_replace: :delete, on_delete: :delete_all, type: :uuid))
      add(:author_id, references(:authors, type: :uuid))

      timestamps()
    end

    create(unique_index(:posts, [:slug, :site_id], name: :slug_unique_index))
    create(index(:posts, [:site_id]))
  end
end
