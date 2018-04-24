defmodule ElephantInTheRoomWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use ElephantInTheRoomWeb, :controller
      use ElephantInTheRoomWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  def controller do
    quote do
      use Phoenix.Controller, namespace: ElephantInTheRoomWeb
      import Plug.Conn
      import ElephantInTheRoomWeb.Router.Helpers
      import ElephantInTheRoomWeb.Gettext
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/elephant_in_the_room_web/templates",
        namespace: ElephantInTheRoomWeb

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_flash: 2, view_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import ElephantInTheRoomWeb.Router.Helpers
      import ElephantInTheRoomWeb.ErrorHelpers
      import ElephantInTheRoomWeb.Gettext
      import ElephantInTheRoomWeb.Utils.ViewUtils
    end
  end

  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
      import Phoenix.Controller
      import ElephantInTheRoomWeb.Plugs.SiteInfo
      import ElephantInTheRoomWeb.Plugs.Admin
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import ElephantInTheRoomWeb.Gettext
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
