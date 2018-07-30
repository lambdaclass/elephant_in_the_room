defmodule ElephantInTheRoom.Repo.Migrations.CreateFeaturedCachedPosts do
  use Ecto.Migration

  def change do
    create table(:featured_cached_posts) do
      add(:level, :integer)
      add(:post_id, :integer)
      add(:site_id, :integer)
    end
  end

end
