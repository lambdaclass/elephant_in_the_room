defmodule ElephantInTheRoom.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add(:title, :string)
      add(:slug, :string)
      add(:abstract, :text)
      add(:content, :text)
      add(:rendered_content, :text)
      add(:image, :text)
      add(:site_id, references(:sites, on_replace: :delete, on_delete: :delete_all))
      add(:author_id, references(:authors))

      timestamps()
    end

    create(index(:posts, [:site_id]))
  end
end
