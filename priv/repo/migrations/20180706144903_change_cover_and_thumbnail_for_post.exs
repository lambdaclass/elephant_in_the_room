defmodule ElephantInTheRoom.Repo.Migrations.ChangeCoverAndThumbnailForPost do
  use Ecto.Migration

  def change do
    alter table("posts") do
      remove :image
      remove :cover
      add :cover, :string
      add :thumbnail, :string
    end
  end
end
