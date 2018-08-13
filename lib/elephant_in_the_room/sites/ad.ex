defmodule ElephantInTheRoom.Sites.Ad do
  import Ecto.Query, warn: false
  use ElephantInTheRoom.Schema
  import Ecto.Changeset
  alias ElephantInTheRoom.{Repo, Sites}
  alias ElephantInTheRoom.Sites.{Ad, Markdown, Site}

  schema "ads" do
    field(:name, :string)
    field(:content, :string)
    field(:rendered_content, :string)
    field(:pos, :integer)
    belongs_to(:site, Site)

    timestamps()
  end

  def changeset, do: changeset(%Ad{}, %{})

  def changeset(%Ad{} = ad, attrs \\ %{}) do
    ad
    |> cast(attrs, [:name, :content, :pos, :site_id])
    |> validate_required([:name, :content, :pos, :site_id])
    |> unique_constraint(:name, name: :unique_ad_name)
    |> Markdown.put_rendered_content()
  end

  def create(%Site{id: site_id}, attrs) do
    attrs = Map.merge(attrs, %{"site_id" => site_id})
    changeset = changeset(%Ad{}, attrs)
    Repo.insert(changeset)
  end

  def get(%Site{id: site_id}, ad_name) when is_binary(ad_name) do
    ad_query =
      from(
        a in Ad,
        where: a.name == ^ad_name and a.site_id == ^site_id
      )

    Repo.one(ad_query)
  end

  def get(%Site{id: site_id}, :all) do
    ads =
      from(
        a in Ad,
        where: a.site_id == ^site_id,
        order_by: [asc: a.pos, desc: a.updated_at]
      )

    Repo.all(ads)
  end

  def get(%Site{id: site_id}, options) do
    %{index: {index_from, _}, bigger_amount: amount} = pagination = Sites.pagination_opts(options)

    ads =
      from(
        a in Ad,
        where: a.site_id == ^site_id,
        order_by: [asc: a.pos, desc: a.updated_at],
        limit: ^amount,
        offset: ^index_from
      )

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
