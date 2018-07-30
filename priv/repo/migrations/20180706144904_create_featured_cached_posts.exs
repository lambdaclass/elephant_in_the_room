defmodule ElephantInTheRoom.Repo.Migrations.CreateFeaturedCachedPosts do
  use Ecto.Migration

  def change do
    create table(:featured_cached_posts) do
      add(:level, :integer)
      add(:post_id, references(:posts, type: :uuid))
      add(:site_id, references(:sites, type: :uuid))
    end
  end

end
