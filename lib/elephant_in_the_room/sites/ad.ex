defmodule ElephantInTheRoom.Sites.Ad do
  import Ecto.Query, warn: false
  use ElephantInTheRoom.Schema
  alias ElephantInTheRoom.Repo
  alias ElephantInTheRoom.Sites.Markdown
  alias ElephantInTheRoom.Sites.Ad
  alias ElephantInTheRoom.Sites.Site
  alias ElephantInTheRoom.Sites
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
    |> Changeset.cast(attrs, [:name, :content, :pos, :site_id])
    |> Changeset.validate_required([:name, :content, :pos, :site_id])
    |> Markdown.put_rendered_content
  end

  def create(%Site{id: site_id}, attrs) do
    attrs = Map.merge(attrs, %{"site_id" => site_id})
    changeset = changeset(%Ad{}, attrs)
    Repo.insert(changeset)
  end

  def get(%Site{id: site_id}, options) do
    %{index: {index_from, _}, amount: amount} = Sites.pagination_opts(options)
    ads = from a in Ad,
      where: a.site_id == ^site_id,
      order_by: [desc: a.pos, desc: a.updated_at],
      limit: ^amount,
      offset: ^index_from

    Repo.all(ads)
  end

end
