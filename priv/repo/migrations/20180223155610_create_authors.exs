defmodule ElephantInTheRoom.Repo.Migrations.CreateAuthors do
  use Ecto.Migration

  def change do
    create table(:authors, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:name, :string)
      add(:image, :string)
      add(:description, :text)
      add(:is_columnist, :boolean)

      timestamps()
    end

    create(unique_index(:authors, [:name]))
  end
end
