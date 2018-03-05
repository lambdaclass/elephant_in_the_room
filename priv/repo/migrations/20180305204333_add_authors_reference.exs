defmodule ElephantInTheRoom.Repo.Migrations.AddAuthorsReference do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add(:author_id, references(:authors, on_replace: :delete, on_delete: :delete_all))
    end
  end
end
