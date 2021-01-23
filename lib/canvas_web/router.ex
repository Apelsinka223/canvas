defmodule CanvasWeb.Router do
  use CanvasWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", CanvasWeb do
    pipe_through :api
  end
end
