defmodule CanvasWeb.Schemas.Schema do
  @moduledoc false
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
    field :fields, list_of(:field) do
      resolve &FieldsResolver.list_fields/2
    end

    field :field, :field do
      arg :field_id, non_null(:uuid)

      resolve &FieldsResolver.field/2
    end

    field :print, :string do
      arg :field_id, non_null(:uuid)

      resolve &FieldsResolver.print/2
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
  end

  object :field do
    field :id, non_null(:uuid)
    field :width, :positive_integer
    field :height, :positive_integer

    field :body, :json do
      resolve fn %{body: body}, _, _ ->
        body =
          body
          |> Enum.map(fn {{x, y}, char} ->
            {"#{x},#{y}", char}
          end)
          |> Map.new()

        Jason.encode(body)
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

  input_object :input_start_point do
    field :x, non_null(:non_negative_integer)
    field :y, non_null(:non_negative_integer)
  end
end
