defmodule CanvasWeb.Router do
  use CanvasWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api" do
    pipe_through :api

    if Mix.env() == :dev do
      forward "/graphiql", Absinthe.Plug.GraphiQL, schema: CanvasWeb.Schemas.Schema
    end

    get "/", Absinthe.Plug, schema: CanvasWeb.Schemas.Schema
    post "/", Absinthe.Plug, schema: CanvasWeb.Schemas.Schema
  end
end
