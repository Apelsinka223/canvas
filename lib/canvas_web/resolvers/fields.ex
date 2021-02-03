defmodule CanvasWeb.Resolvers.Fields do
  alias Canvas.Fields

  def create_field(params, _) do
    Fields.create_field(params)
  end

  def field(%{field_id: field_id}, _) do
    Fields.get_field(field_id)
  end

  def add_rectangle(%{field_id: field_id, rectangle: rectangle}, _) do
    with {:ok, field} <- Fields.get_field(field_id) do
      Fields.add_rectangle(field, rectangle)
    end
  end

  def add_flood_fill(%{field_id: field_id, flood_fill: flood_fill}, _) do
    with {:ok, field} <- Fields.get_field(field_id) do
      Fields.add_flood_fill(field, flood_fill)
    end
  end
end
