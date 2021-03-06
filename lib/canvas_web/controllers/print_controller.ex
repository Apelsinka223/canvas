defmodule CanvasWeb.Controllers.Print do
  use CanvasWeb, :controller

  alias Canvas.Fields

  def print(conn, %{"field_id" => field_id}) do
    with {:ok, field} <- Fields.get_field(field_id) do
      conn
      |> text(Fields.print(field))
    end
  end
end
