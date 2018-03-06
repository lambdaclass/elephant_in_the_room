defmodule ElephantInTheRoomWeb.Router do
  use ElephantInTheRoomWeb, :router

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
    pipe_through(:browser)

    get("/", PageController, :index)

    resources "/sites", SiteController do
      pipe_through(:load_site_info)
      resources("/categories", CategoryController)
      resources("/posts", PostController)
      resources("/tags", TagController)
    end

    resources("/roles", RoleController)
    resources("/users", UserController)
    resources("/authors", AuthorController)
  end
end
