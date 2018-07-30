defmodule ElephantInTheRoom.Repo.Migrations.CreateFeedback do
  use Ecto.Migration

  def change do
    create table(:feedbacks) do
      add(:text, :string)
      add(:email, :string)
      add(:site_id, references(:sites, on_delete: :delete_all))

      timestamps()
    end
    create(index(:feedbacks, [:site_id]))
  end
end
