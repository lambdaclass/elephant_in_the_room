defmodule ElephantInTheRoomWeb.Router do
  use ElephantInTheRoomWeb, :router
  import ElephantInTheRoomWeb.Plugs.SetSite

  pipeline :auth do
    plug(ElephantInTheRoom.Auth.Pipeline)
  end

  pipeline :ensure_auth do
    plug(Guardian.Plug.EnsureAuthenticated)
  end

  pipeline :image_uploading do
    plug(:fetch_session)
    plug(:put_secure_browser_headers)
    plug(ElephantInTheRoom.Auth.Pipeline)
    plug(Guardian.Plug.EnsureAuthenticated)
  end

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :site_required do
    plug(:set_site)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope path: "/images", alias: ElephantInTheRoomWeb do
    scope "/" do
      pipe_through([:image_uploading])
      post("/", ImageController, :save_image)
      post("/binary", ImageController, :save_binary_image)
    end

    get("/:id", ImageController, :get_image)
  end

  scope "/", ElephantInTheRoomWeb do
    pipe_through([:browser, :auth])

    get("/login", LoginController, :index)
    post("/login", LoginController, :login)
    get("/logout", LoginController, :logout)

    scope "/" do
      pipe_through([:site_required])
      get("/", SiteController, :public_show)
      get("/latest", SiteController, :public_show_latest)
      get("/popular", SiteController, :public_show_popular)
      get("/author/:author_name", AuthorController, :public_show)
      get("/post/:year/:month/:day/:slug", PostController, :public_show)
      get("/category/:category_name", CategoryController, :public_show)
      get("/tag/:tag_name", TagController, :public_show)
    end

    scope "/admin" do
      pipe_through([:on_admin_page, :ensure_auth])
      get("/", AdminController, :index)
      resources("/roles", RoleController)
      resources("/users", UserController)
      resources("/authors", AuthorController, param: "author_name")
      get("/backup", BackupController, :index)
      post("/backup/do_backup", BackupController, :do_backup)
      get("/backup/download_latest", BackupController, :download_latest)
      get("/backup/modify_settings", BackupController, :get_modify_settings)

      resources "/sites", SiteController do
        pipe_through(:load_site_info)
        resources("/categories", CategoryController, param: "category_name")
        resources("/posts", PostController)
        resources("/tags", TagController, param: "tag_name")
      end
    end
  end
end
