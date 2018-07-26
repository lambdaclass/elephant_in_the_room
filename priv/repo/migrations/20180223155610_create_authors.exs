defmodule ElephantInTheRoom.Repo.Migrations.CreateAuthors do
  use Ecto.Migration

  def change do
    create table(:authors) do
      add(:name, :string)
      add(:image, :string)
      add(:description, :text)
      add(:is_columnist, :boolean)

      timestamps()
    end

    create(unique_index(:authors, [:name]))
  end
end
