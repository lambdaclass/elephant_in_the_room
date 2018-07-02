use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :elephant_in_the_room, ElephantInTheRoomWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :elephant_in_the_room, ElephantInTheRoom.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "elephant_in_the_room_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

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
