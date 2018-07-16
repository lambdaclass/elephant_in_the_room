use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :elephant_in_the_room, ElephantInTheRoomWeb.Endpoint,
  http: [port: 4000],
  debug_errors: false,
  code_reloader: true,
  check_origin: false,
  watchers: [
    node: [
      "node_modules/brunch/bin/brunch",
      "watch",
      "--stdin",
      cd: Path.expand("../assets", __DIR__)
    ]
  ]

# ## SSL Support
#
# In order to use HTTPS in development, a self-signed
# certificate can be generated by running the following
# command from your terminal:
#
#     openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=www.example.com" -keyout priv/server.key -out priv/server.pem
#
# The `http:` config above can be replaced with:
#
#     https: [port: 4000, keyfile: "priv/server.key", certfile: "priv/server.pem"],
#
# If desired, both `http:` and `https:` keys can be
# configured to run both http and https servers on
# different ports.

# Watch static and templates for browser reloading.
config :elephant_in_the_room, ElephantInTheRoomWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{lib/elephant_in_the_room_web/views/.*(ex)$},
      ~r{lib/elephant_in_the_room_web/templates/.*(eex)$}
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Configure your database
config :elephant_in_the_room, ElephantInTheRoom.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "elephant_in_the_room_dev",
  hostname: "localhost",
  pool_size: 10

##
## Cookies & Auth
##
config :elephant_in_the_room, ElephantInTheRoomWeb.Endpoint,
  secret_key_base: "nzdAWjDdDu8NoQlv0Hhk3Q08LtZ/fLPUoyTR5j+wTN1kPPiGEDRCoKmI4Ftl65V1",
  signing_salt: "H8osk+zCmp8zhgxNjtoTuSDfj5T2rRV80uqhF6mOhEQF",
  encryption_salt: "LL0FHuwYWDy5uYsadZPSrYzdZdrUmmApt07Nl1sQ1wA2"

config :elephant_in_the_room, ElephantInTheRoom.Auth.Guardian,
  issuer: "elephant_in_the_room",
  secret_key: "UipYx0z54wtvC8EZ0bavPWkaCk5gFvu/9caWXb/fwiALISfAVDrvlIq5JPGMuE8J"
