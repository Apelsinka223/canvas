defmodule CanvasWeb.Schemas.Schema do
  use Absinthe.Schema

  alias CanvasWeb.Resolvers.Fields, as: FieldsResolver

  import_types Absinthe.Plug.Types
  import_types Absinthe.Type.Custom
  import_types Canvas.Schemas.CustomTypes

  def plugins do
    Absinthe.Plugin.defaults()
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
      arg :width, :positive_integer
      arg :height, :positive_integer

      resolve &FieldsResolver.create_field/2
    end

    field :add_rectangle, :field do
      arg :field_id, non_null(:uuid)
      arg :rectangle, non_null(:input_rectangle)

      resolve &FieldsResolver.add_rectangle/2
    end

    field :add_flood_fill, :field do
      arg :field_id, non_null(:uuid)
      arg :flood_fill, non_null(:input_flood_fill)

      resolve &FieldsResolver.add_flood_fill/2
    end
  end

  subscription do
  end

  object :field do
    field :id, non_null(:uuid)
    field :width, :positive_integer
    field :height, :positive_integer
    field :body, :json do
      resolve fn %{body: body}, _, _ ->
        body = Enum.map(body, fn {{x, y}, v} -> {Jason.encode!(%{x: x, y: y}), v} end) |> Map.new()
        Jason.encode(body) |> IO.inspect
      end
    end
  end

  input_object :input_rectangle do
    field :start_point, non_null(:input_start_point)
    field :width, non_null(:positive_integer)
    field :height, non_null(:positive_integer)
    field :outline_char, :char
    field :fill_char, :char
  end

  input_object :input_flood_fill do
    field :start_point, non_null(:input_start_point)
    field :fill_char, :char
  end

  input_object :input_start_point do
    field :x, non_null(:positive_integer)
    field :y, non_null(:positive_integer)
  end
end
