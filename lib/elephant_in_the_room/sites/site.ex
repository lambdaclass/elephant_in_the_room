defmodule ElephantInTheRoom.Sites.Site do
  use ElephantInTheRoom.Schema
  import Ecto.Changeset
  alias Ecto.Changeset
  alias ElephantInTheRoomWeb.Uploaders.Image
  alias ElephantInTheRoom.Sites
  alias ElephantInTheRoom.Sites.{Site, Category, Post, Tag, Author}

  schema "sites" do
    field(:name, :string)
    field(:host, :string)
    field(:image, :string)
    field(:description, :string)
    field(:favicon, :string)
    field(:title, :string)
    field(:post_default_image, :string)

    has_many(:categories, Category, on_delete: :delete_all)
    has_many(:posts, Post, on_delete: :delete_all)
    has_many(:tags, Tag, on_delete: :delete_all)
    many_to_many(:authors, Author, join_through: Post)

    timestamps()
  end

  @doc false
  def changeset(%Site{} = site, attrs) do
    new_attrs = put_title(attrs)

    site
    |> cast(new_attrs, [:name, :host, :description, :title])
    |> validate_required([:name, :host])
    |> unique_constraint(:name)
    |> unique_constraint(:host)
    |> store_image(attrs)
    |> validate_favicon(attrs)
    |> check_title(attrs)
    |> check_post_default_image(attrs)
  end

  defp check_post_default_image(%Changeset{} = changeset, %{"post_default_image" => nil}),
    do: Changeset.put_change(changeset, :post_default_image, nil)

  defp check_post_default_image(%Changeset{valid?: false} = changeset, _attrs),
    do: changeset

  defp check_post_default_image(%Changeset{} = changeset, %{"post_default_image" => post_image})
       when post_image != nil do
    {:ok, image_name} = Image.store(%{post_image | filename: Ecto.UUID.generate()})
    Changeset.put_change(changeset, :post_default_image, "/images/#{image_name}")
  end

  defp check_post_default_image(%Changeset{} = changeset, attrs) do
    default = Sites.get_image_by_name!("grey_placeholder")

    if Map.has_key?(attrs, :post_default_image),
      do: changeset,
      else: Changeset.put_change(changeset, :post_default_image, "/images/#{default.name}")
  end

  defp put_title(attrs) do
    if Map.has_key?(attrs, :title),
      do: Map.put(attrs, :title, nil),
      else: attrs
  end

  def check_title(%Changeset{} = changeset, %{"title" => title})
      when title != "" and title != nil,
      do: changeset

  def check_title(%Changeset{} = changeset, %{"name" => name}),
    do: Changeset.put_change(changeset, :title, name)

  def check_title(%Changeset{} = changeset, _attrs), do: changeset

  def store_image(%Changeset{valid?: false} = changeset, _attrs) do
    changeset
  end

  def store_image(%Changeset{} = changeset, %{"image" => nil}),
    do: Changeset.put_change(changeset, :image, nil)

  def store_image(%Changeset{} = changeset, %{"image" => image}) do
    {:ok, image_name} = Image.store(%{image | filename: Ecto.UUID.generate()})

    Changeset.put_change(changeset, :image, "/images/#{image_name}")
  end

  def store_image(%Changeset{} = changeset, _attrs), do: changeset

  def validate_favicon(%Changeset{valid?: false} = changeset, _attrs) do
    changeset
  end

  def validate_favicon(%Changeset{} = changeset, %{"favicon" => nil}),
    do: put_change(changeset, :favicon, nil)

  def validate_favicon(
        %Changeset{} = changeset,
        %{"favicon" => %Plug.Upload{content_type: ct} = favicon}
      ) do
    if valid_favicon?(ct) do
      {:ok, favicon_name} = Image.store(%{favicon | filename: Ecto.UUID.generate()})

      Changeset.put_change(changeset, :favicon, "/images/#{favicon_name}")
    else
      Changeset.add_error(changeset, :favicon, "El icono debe tener extensión .ico")
    end
  end

  def validate_favicon(%Changeset{} = changeset, _attrs), do: changeset

  defp valid_favicon?("image/vnd.microsoft.icon"), do: true
  defp valid_favicon?("image/x-icon"), do: true
  defp valid_favicon?(_content_type), do: false
end
