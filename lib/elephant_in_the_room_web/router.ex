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
    pipe_through(:browser)

    get("/", PageController, :index)

    resources "/sites", SiteController do
      resources "/categories", CategoryController do
        resources("/posts", PostController)
      end
    end
  end
end
