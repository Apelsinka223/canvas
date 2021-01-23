defmodule CanvasWeb.Resolvers.Fields do
  alias Canvas.Fields

  def create_field(params, _) do
    Fields.create_field(params)
  end

  def field(%{field_id: field_id}, _) do
    Fields.get_field(field_id)
  end
end
