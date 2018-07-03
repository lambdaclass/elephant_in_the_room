defmodule ElephantInTheRoom.Repo.Migrations.AddNameToImages do
  use Ecto.Migration

  def change do
    alter table("images") do
      add :name, :string
    end
  end
end
