defmodule ElephantInTheRoom.Repo.Migrations.CreateImages do
  use Ecto.Migration

  def change do
    create table(:images) do
      add :binary, :binary
      add :type, :string

      timestamps()
    end

  end
end
