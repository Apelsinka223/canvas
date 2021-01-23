defmodule Canvas.Schema do
  use Absinthe.Schema

  alias CanvasWeb.Resolvers.Fields, as: FieldsResolver

  import_types Absinthe.Plug.Types
  import_types Absinthe.Type.Custom
  import_types Canvas.Schemas.CustomTypes

  def dataloader do
    Dataloader.new()
  end

  def context(ctx) do
    Map.put(ctx, :loader, dataloader())
  end

  def plugins do
    [Absinthe.Middleware.Dataloader] ++ Absinthe.Plugin.defaults()
  end

  def middleware(middleware, _field, _object) do
    middleware
  end

  query do
    field :field, :field do
      arg :field_id, non_null(:uuid)

      resolve &FieldsResolver.field/2
    end
  end

  mutation do
    field :create_field, :field do
      arg :size, :positive_integer

      resolve &FieldsResolver.create_field/2
    end
  end

  subscription do
  end

  object :field do
    field :id, non_null(:uuid)
    field :size, :positive_integer
  end
end
