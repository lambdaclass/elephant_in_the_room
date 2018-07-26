defmodule ElephantInTheRoom.Repo.Migrations.CreateFeaturedCachedPosts do
  create table(:featured_cached_posts) do
    add(:level, :integer)
    add(:post_id, :integer)
  end
end
