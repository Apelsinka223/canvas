defmodule CanvasWeb.Resolvers.Fields do
  @moduledoc false
  alias Canvas.Fields

  def create_field(params, _) do
    Fields.create_field(params)
  end

  def list_fields(_, _) do
    {:ok, Fields.list_fields()}
  end

  def field(%{field_id: field_id}, _) do
    Fields.get_field(field_id)
  end

  def add_rectangle(%{field_id: field_id, rectangle: rectangle}, _) do
    with {:ok, field} <- Fields.get_field(field_id) do
      Fields.add_rectangle(field, rectangle)
    end
  end

  def print(%{field_id: field_id}, _) do
    with {:ok, field} <- Fields.get_field(field_id) do
      {:ok, Fields.print(field)}
    end
  end
end
