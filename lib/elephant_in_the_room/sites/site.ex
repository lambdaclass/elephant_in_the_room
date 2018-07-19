defmodule ElephantInTheRoom.Sites.Site do
  use Ecto.Schema
  import Ecto.Changeset
  alias Ecto.Changeset
  alias ElephantInTheRoomWeb.{SiteView, Uploaders.Image, Utils.Utils}
  alias ElephantInTheRoom.Sites.{Site, Category, Post, Tag, Author}

  schema "sites" do
    field(:name, :string)
    field(:host, :string)
    field(:image, :string)
    field(:description, :string)

    has_many(:categories, Category, on_delete: :delete_all)
    has_many(:posts, Post, on_delete: :delete_all)
    has_many(:tags, Tag, on_delete: :delete_all)
    many_to_many(:authors, Author, join_through: Post)

    timestamps()
  end

  @doc false
  def changeset(%Site{} = site, attrs) do
    site
    |> cast(attrs, [:name, :host, :description])
    |> validate_required([:name, :host])
    |> unique_constraint(:name)
    |> unique_constraint(:host)
    |> store_image(attrs)
  end

  def store_image(%Changeset{} = changeset, %{"image" => nil}) do
    put_change(changeset, :image, nil)
  end

  def store_image(%Changeset{} = changeset, %{"image" => image}) do
    {:ok, image_name} = Image.store(%{image | filename: Ecto.UUID.generate()})

    put_change(changeset, :image, "/images/" <> image_name)
  end

  def store_image(%Changeset{} = changeset, _attrs) do
    changeset
  end

  def generate_og_meta(conn) do
    [url, image] =
      [SiteView.show_site_link(conn), conn.assigns.site.image]
      |> Enum.map(fn path -> Utils.generate_absolute_url(path, conn) end)

    %{
      url: url,
      type: "website",
      title: "#{conn.assigns.site.name}",
      description: conn.assigns.site.description,
      image: image
    }
  end
end
