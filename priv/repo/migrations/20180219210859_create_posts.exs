defmodule ElephantInTheRoom.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add(:title, :string)
      add(:image, :string)
      add(:content, :string)
      add(:tag, {:array, :string})

      add(:category_id, references(:categories))

      timestamps()
    end
  end
end
