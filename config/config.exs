# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :phx_and_graphql,
  ecto_repos: [PhxAndGraphql.Repo]

# Configures the endpoint
config :phx_and_graphql, PhxAndGraphqlWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "PO6L7wFWOPg18hgEBA+JhO5Eent3xoV4J2olBpQm1XN+zuvdck7CskneaGPXPuJ9",
  render_errors: [view: PhxAndGraphqlWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: PhxAndGraphql.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
