defmodule ElephantInTheRoomWeb.Router do
  use ElephantInTheRoomWeb, :router

  pipeline :auth do
    plug(ElephantInTheRoom.Auth.Pipeline)
  end

  pipeline :ensure_auth do
    plug(Guardian.Plug.EnsureAuthenticated)
  end

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", ElephantInTheRoomWeb do
    # Use the default browser stack
    pipe_through([:browser, :auth])

    get("/", PageController, :index)
    get("/login", LoginController, :index)
    post("/login", LoginController, :login)
    post("/logout", LoginController, :logout)
    resources("/users", UserController, only: [:new, :create])

    scope "/site" do
      pipe_through(:load_site_info)
      get("/:site_id", SiteController, :public_show)
      get("/:site_id/post/:post_id", PostController, :public_show)
      get("/:site_id/category/:category_id", CategoryController, :public_show)
      get("/:site_id/tags", TagController, :public_show)
    end

    scope "/admin" do
      pipe_through([:on_admin_page, :ensure_auth])
      get("/", AdminController, :index)
      resources("/roles", RoleController)
      resources("/users", UserController, except: [:new, :create])

      get("/secret", LoginController, :secret)
      resources("/authors", AuthorController)

      resources "/sites", SiteController do
        pipe_through(:load_site_info)
        resources("/categories", CategoryController)
        resources("/posts", PostController)
        resources("/tags", TagController)
      end
    end
  end
end
