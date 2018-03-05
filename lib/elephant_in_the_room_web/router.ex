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

    scope "/sites", SiteController do
      pipe_through :load_site_info
      get "/categories", CategoryController, :display
      get "/posts", PostController, :display
      get "/tags", TagController, :displayxs
    end

    scope "/admin" do
      pipe_through :on_admin_page
      get "/", AdminController, :index
      resources "/sites", SiteController do
        pipe_through :load_site_info
        resources "/categories", CategoryController
        resources "/posts", PostController
        resources "/tags", TagController
      end
    end    
    
  end
end
