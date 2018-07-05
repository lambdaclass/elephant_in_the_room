defmodule ElephantInTheRoom.Repo.Migrations.PostsUseImageAndCover do
  use Ecto.Migration

  def change do
    alter table("posts") do
      remove :thumbnail
      remove :cover
      add :image, :string
      add :cover, :boolean
    end
  end
end
