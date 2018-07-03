# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :example_app,
  ecto_repos: [ExampleApp.Repo]

# Configures the endpoint
config :example_app, ExampleAppWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "f2MBhR/IEl4JQ/+DatT9LifjD2cVF8HVY5C+dUyN34Vtm21BtTqM7EPwK4r2o1DE",
  render_errors: [view: ExampleAppWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: ExampleApp.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
