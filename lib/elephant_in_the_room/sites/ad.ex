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

  def changeset(), do: changeset(%Ad{}, %{})
  def changeset(%Ad{} = ad, attrs \\ %{}) do
    ad
    |> Changeset.cast(attrs, [:name, :content, :pos, :site_id])
    |> Changeset.validate_required([:name, :content, :pos, :site_id])
    |> Changeset.unique_constraint(:name)
    |> Markdown.put_rendered_content
  end

  def create(%Site{id: site_id}, attrs) do
    attrs = Map.merge(attrs, %{"site_id" => site_id})
    changeset = changeset(%Ad{}, attrs)
    Repo.insert(changeset)
  end

  def get(%Site{id: site_id}, ad_name) when is_binary(ad_name) do
    ad_query = from a in Ad,
      where: a.name == ^ad_name and a.site_id == ^site_id

    Repo.one(ad_query)
  end
  def get(%Site{id: site_id}, :all) do
    ads = from a in Ad,
      where: a.site_id == ^site_id,
      order_by: [asc: a.pos, desc: a.updated_at]
    Repo.all(ads)
  end
  def get(%Site{id: site_id}, options) do
    %{index: {index_from, _}, bigger_amount: amount} = pagination =
      Sites.pagination_opts(options)
    ads = from a in Ad,
      where: a.site_id == ^site_id,
      order_by: [asc: a.pos, desc: a.updated_at],
      limit: ^amount,
      offset: ^index_from

    ads_query_result = Repo.all(ads)
    Sites.pagination_result(ads_query_result, pagination)
  end

  def update(ad, attrs) do
    changeset = changeset(ad, attrs)
    Repo.update(changeset)
  end

  def delete(%Site{} = site, ad_name) when is_binary(ad_name) do
    case Ad.get(site, ad_name) do
      %Ad{} = ad -> Repo.delete(ad)
      _ -> {:error, :not_exists}
    end
  end

end
