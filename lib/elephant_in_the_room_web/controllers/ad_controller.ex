defmodule ElephantInTheRoomWeb.AdController do
  use ElephantInTheRoomWeb, :controller
  import ElephantInTheRoomWeb.Utils.Utils, only: [get_page: 1]
  alias ElephantInTheRoom.Sites.Ad

  def index(conn, params) do
    site = conn.assigns.site
    page = get_page(params)
    ads = Ad.get(site, amount: 10, page: page)
    render(conn, "index.html",
      ads: ads,
      bread_crumb: [:sites, site, :ads])
  end

  def edit(conn, %{"ad_name" => ad_name}) do
    site = conn.assigns.site
    ad = Ad.get(site, ad_name)
    changeset = Ad.changeset(ad)
    render(conn, "edit.html",
      ad: ad,
      changeset: changeset,
      bread_crumb: [:sites, site, :ads, ad])
  end

  def update(conn, %{"ad_name" => ad_name} = attrs) do
    site = conn.assigns.site
    ad = Ad.get(site, ad_name)
    case Ad.update(ad, attrs["ad"]) do
      {:ok, updated_ad} -> redirect(conn, to:
        site_ad_path(conn, :edit, site.name, updated_ad.name))
      {:error, changeset} ->
        render(conn,
          ad: ad,
          changeset: changeset,
          bread_crumb: [:sites, site, :ads, ad])
    end
  end

  def new(conn, _params) do
    site = conn.assigns.site
    render(conn, "new.html",
      changeset: Ad.changeset(),
      bread_crumb: [:sites, site, :ads, :new])
  end

end
