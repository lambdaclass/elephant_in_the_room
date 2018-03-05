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
      pipe_through :load_site_info
      resources "/categories", CategoryController, only: [:show]
      resources "/posts", PostController, only: [:show]
      resources "/tags", TagController, only: [:show]
    end

    scope "/admin" do
      resources "/sites", SiteController do
        pipe_through :load_site_info
        resources "/categories", CategoryController, except: [:show]
        resources "/posts", PostController, except: [:show]
        resources "/tags", TagController, except: [:show]
      end
    end
    
  end
end
