defmodule ElephantInTheRoom.Repo.Migrations.CreatePostsTags do
  use Ecto.Migration

  def change do
    create table(:posts_tags, primary_key: false) do
      add(:post_id, references(:posts), on_delete: :delete_all)
      add(:tag_id, references(:tags), on_delete: :delete_all)
    end

    create(unique_index(:tags, [:name]))
  end
end
