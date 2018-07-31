defmodule ElephantInTheRoom.Repo.Migrations.AddAdsTable do
  use Ecto.Migration

  def change do
    create table(:ads) do
      add(:name, :string)
      add(:content, :string)
      add(:rendered_content, :string)
      add(:pos, :integer)
      add(:site_id, references(:sites, on_delete: :delete_all, type: :uuid))
      timestamps()
    end
  end
end
