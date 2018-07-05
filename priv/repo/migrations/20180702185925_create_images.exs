defmodule ElephantInTheRoom.Repo.Migrations.CreateImages do
  use Ecto.Migration

  def change do
    create table(:images) do
      add :binary, :binary

      timestamps()
    end

  end
end
