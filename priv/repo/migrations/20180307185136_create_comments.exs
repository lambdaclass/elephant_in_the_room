defmodule ElephantInTheRoom.Repo.Migrations.CreateComments do
  use Ecto.Migration

  def change do
    create table(:comments) do
      add :text, :string
      add :post_id, references(:posts,
        on_replace: :delete, on_delete: :delete_all)
      add :user_id, references(:users,
        on_replace: :delete, on_delete: :delete_all)

      timestamps()
    end

  end
end
