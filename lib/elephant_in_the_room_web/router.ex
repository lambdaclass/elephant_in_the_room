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

  # local routes
  scope path: "/", host: "localhost", alias: ElephantInTheRoomWeb do
    pipe_through([:browser, :auth])
    get("/", LoginController, :index)
    post("/login", LoginController, :login)
    get("/logout", LoginController, :logout)

    scope "/admin" do
      pipe_through([:on_admin_page, :ensure_auth])
      get("/", AdminController, :index)
      resources("/roles", RoleController)
      resources("/users", UserController)
      resources("/authors", AuthorController)
      get("/backup", BackupController, :index)
      post("/backup/do_backup", BackupController, :do_backup)
      get("/backup/download_latest", BackupController, :download_latest)
      get("/backup/modify_settings", BackupController, :get_modify_settings)
    end
  end

  scope "/", ElephantInTheRoomWeb do
    pipe_through([:browser, :auth])

    get("/", SiteController, :public_show)
    get("/login", LoginController, :index)
    post("/login", LoginController, :login)
    get("/logout", LoginController, :logout)
    get("/author/:author_id", AuthorController, :public_show)

    get("/post/:year/:month/:day/:slug", PostController, :public_show)
    get("/category/:category_id", CategoryController, :public_show)
    get("/tag/:tag_id", TagController, :public_show)

    scope "/admin" do
      pipe_through([:on_admin_page, :ensure_auth])
      get("/", AdminController, :index)
      resources("/roles", RoleController)
      resources("/users", UserController)
      resources("/authors", AuthorController)
      get("/backup", BackupController, :index)
      post("/backup/do_backup", BackupController, :do_backup)
      get("/backup/download_latest", BackupController, :download_latest)
      get("/backup/modify_settings", BackupController, :get_modify_settings)

      resources "/sites", SiteController do
        pipe_through(:load_site_info)
        resources("/categories", CategoryController)
        resources("/posts", PostController)
        resources("/tags", TagController)
      end
    end
  end
end
