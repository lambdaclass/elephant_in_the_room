defmodule ElephantInTheRoom.Repo.Migrations.AddCoverAndThumbnailToPosts do
  use Ecto.Migration

  def change do
    rename table("posts"), :image, to: :cover
    alter table("posts") do
      add :thumbnail, :string
    end
  end
end
