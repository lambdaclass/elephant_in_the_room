# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :elephant_in_the_room, ecto_repos: [ElephantInTheRoom.Repo]

# Configures the endpoint
config :elephant_in_the_room, ElephantInTheRoomWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: ElephantInTheRoomWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: ElephantInTheRoom.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :arc, storage: Arc.Storage.Local

config :elephant_in_the_room, ElephantInTheRoom.Repo,
  migration_primary_key: [id: :uuid, type: :binary_id]
# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
