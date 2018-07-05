defmodule PhxAndGraphqlWeb.Router do
  use PhxAndGraphqlWeb, :router

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

  scope "/", PhxAndGraphqlWeb do
    # Use the default browser stack
    pipe_through(:browser)

    get("/", PageController, :index)
  end

  # Other scopes may use custom stacks.
  # scope "/api", PhxAndGraphqlWeb do
  #   pipe_through :api
  # end

  forward(
    "/graphql",
    Absinthe.Plug,
    schema: PhxAndGraphqlWeb.Graphql.Schema
  )

  # For the GraphiQL interactive interface, a must-have for happy frontend devs.
  forward(
    "/graphiql",
    Absinthe.Plug.GraphiQL,
    schema: PhxAndGraphqlWeb.Graphql.Schema,
    interface: :simple
  )
end
