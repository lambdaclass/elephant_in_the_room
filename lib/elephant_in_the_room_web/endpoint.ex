defmodule ElephantInTheRoomWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :elephant_in_the_room
  import ElephantInTheRoomWeb.Utils.Utils, only: [get_env: 2]

  socket("/socket", ElephantInTheRoomWeb.UserSocket)

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phoenix.digest
  # when deploying your static files in production.
  plug(
    Plug.Static,
    at: "/",
    from: :elephant_in_the_room,
    gzip: false,
    only: ~w(css fonts webfonts images js favicon.ico robots.txt)
  )

  plug(Plug.Static, at: "/uploads", from: Path.expand('./uploads'), gzip: false)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket("/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket)
    plug(Phoenix.LiveReloader)
    plug(Phoenix.CodeReloader)
  end

  plug(Plug.RequestId)
  plug(Plug.Logger)

  plug(
    Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison
  )

  plug(Plug.MethodOverride)
  plug(Plug.Head)

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  plug(
    Plug.Session,
    store: :cookie,
    key: "_elephant_in_the_room_key",
    signing_salt: get_env(__MODULE__, :signing_salt),
    encryption_salt: get_env(__MODULE__, :encryption_salt)
  )

  plug(ElephantInTheRoomWeb.Router)

  def init(_key, config) do
    if config[:load_from_system_env] do
      port = System.get_env("PORT") || raise "expected the PORT environment variable to be set"
      {:ok, Keyword.put(config, :http, [:inet6, port: port])}
    else
      {:ok, config}
    end
  end
end
