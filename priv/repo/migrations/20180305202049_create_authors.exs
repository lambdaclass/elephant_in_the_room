defmodule ElephantInTheRoom.Repo.Migrations.CreateAuthors do
  use Ecto.Migration

  def change do
    create table(:authors) do
      add(:name, :string)
      add(:image, :string)
      add(:description, :string)

      timestamps()
    end

    create(unique_index(:authors, [:name]))
  end
end
