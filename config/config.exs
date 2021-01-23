# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :canvas,
  ecto_repos: [Canvas.Repo]

# Configures the endpoint
config :canvas, CanvasWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Qzv38HkseZJDVZzxymejzXJPaYLi0ctIXZRq3Z2EsYWfy/J/SF9wbKfJiURDLoM8",
  render_errors: [view: CanvasWeb.ErrorView, accepts: ~w(json), field: false],
  pubsub_server: Canvas.PubSub,
  live_view: [signing_salt: "mEWkSqZu"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
