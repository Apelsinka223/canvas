defmodule CanvasWeb.Router do
  use CanvasWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/api" do
    pipe_through :api

    if Mix.env() == :dev do
      forward "/graphiql", Absinthe.Plug.GraphiQL, schema: CanvasWeb.Schemas.Schema
    end

    get "/", Absinthe.Plug, schema: CanvasWeb.Schemas.Schema
    post "/", Absinthe.Plug, schema: CanvasWeb.Schemas.Schema
  end

  scope "/" do
    pipe_through :browser

    get "/print/:field_id", CanvasWeb.Controllers.Print, :print
  end
end
