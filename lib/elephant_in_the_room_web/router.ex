defmodule ElephantInTheRoomWeb.Router do
  use ElephantInTheRoomWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ElephantInTheRoomWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/hello", HelloController, :index
    get "/hello/:messenger", HelloController, :show
  end

  scope "/post", ElephantInTheRoomWeb do
    pipe_through :browser

    get  "/creation_form",   PostController, :creation_form
    post "/submit_new",      PostController, :create_new
    get  "/list",            PostController, :list_all_posts
    get  "/read/:post_name", PostController, :read
  end

  # Other scopes may use custom stacks.
  # scope "/api", ElephantInTheRoomWeb do
  #   pipe_through :api
  # end
end
