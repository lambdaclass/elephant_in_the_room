defmodule ElephantInTheRoomWeb.Router do
  use ElephantInTheRoomWeb, :router
  import ElephantInTheRoomWeb.Plugs.SetSite
  alias ElephantInTheRoom.Auth

  pipeline :auth do
    plug(Auth.Pipeline)
  end

  pipeline :ensure_auth do
    plug(Guardian.Plug.EnsureAuthenticated)
  end

  pipeline :image_uploading do
    plug(:fetch_session)
    plug(:put_secure_browser_headers)
    plug(Auth.Pipeline)
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

    get("/:name", ImageController, :get_image)
  end

  scope "/", ElephantInTheRoomWeb do
    pipe_through([:browser, :auth])

    get("/login", LoginController, :index)
    post("/login", LoginController, :login)
    get("/logout", LoginController, :logout)

    scope "/" do
      pipe_through([:site_required])
      get("/", SiteController, :public_show)
      post("/feedback", FeedbackController, :create)
      get("/latest", SiteController, :public_show_latest)
      get("/popular", SiteController, :public_show_popular)
      get("/author/:author_name", AuthorController, :public_show)
      get("/post/:year/:month/:day/:slug", PostController, :public_show)
      get("/category/:category_name", CategoryController, :public_show)
      get("/tag/:tag_name", TagController, :public_show)
      get("/magazine", MagazineController, :current)
      get("/magazine/:title", MagazineController, :public_show)
      get("/magazine/:magazine_title/post/:year/:month/:day/:slug", PostController, :public_show, as: "magazine_post")
      get("/magazines", MagazineController, :public_index)
    end

    scope "/admin" do
      pipe_through([:on_admin_page, :ensure_auth])
      get("/", AdminController, :index)
      resources("/roles", RoleController, param: "role_name")
      resources("/users", UserController, param: "user_name")
      resources("/authors", AuthorController, param: "author_name")
      get("/backup", BackupController, :index)
      post("/backup/do_backup", BackupController, :do_backup)
      get("/backup/download_latest", BackupController, :download_latest)
      get("/backup/modify_settings", BackupController, :get_modify_settings)

      resources "/sites", SiteController, param: "name" do
        pipe_through(:load_site_info)
        get("/feedback", FeedbackController, :index)
        get("/feedback/:id", FeedbackController, :show)
        delete("/feedback/:id", FeedbackController, :delete)
        resources("/categories", CategoryController, param: "category_name")
        resources("/posts", PostController, param: "slug")
        resources("/tags", TagController, param: "tag_name")
        resources("/ads", AdController, param: "ad_name")
        resources "/magazines", MagazineController, param: "title", except: [:show] do
          resources("/posts", PostController, param: "slug", except: [:show])
        end
      end
    end
  end
end
