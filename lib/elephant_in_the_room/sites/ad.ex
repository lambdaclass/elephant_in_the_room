defmodule ElephantInTheRoom.Sites.Ad do
  use ElephantInTheRoom.Schema
  alias ElephantInTheRoom.Sites.Markdown
  alias ElephantInTheRoom.Sites.Ad
  alias ElephantInTheRoom.Sites.Site
  alias Ecto.Changeset

  schema "ads" do
    field(:name, :string)
    field(:content, :string)
    field(:rendered_content, :string)
    field(:pos, :integer)
    belongs_to(:site, Site, foreign_key: :site_id)
    timestamps()
  end

  def changeset(%Ad{} = ad, attrs \\ []) do
    ad
    |> Changeset.cast(attrs, [:name, :content, :pos])
    |> Changeset.validate_required([:name, :content, :pos])
    |> Markdown.put_rendered_content
  end

end
