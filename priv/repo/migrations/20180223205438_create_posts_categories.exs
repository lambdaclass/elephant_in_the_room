defmodule ElephantInTheRoom.Repo.Migrations.CreatePostsCategories do
  use Ecto.Migration

  def change do
    create table(:posts_categories, primary_key: false) do
      add(:post_id, references(:posts))
      add(:category_id, references(:categories))
    end
  end
end
