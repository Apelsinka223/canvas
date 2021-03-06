defmodule Canvas.Drawing.Rectangle do
  @moduledoc """
  The Draw context.
  """

  import Ecto.Query, warn: false
  alias Canvas.Drawing
  alias Canvas.Drawing.Coordinate

  @type t :: %__MODULE__{
          start_point: Coordinate.t(),
          width: pos_integer(),
          height: pos_integer(),
          outline_char: String.t(),
          fill_char: String.t()
        }

  defstruct [:start_point, :width, :height, :outline_char, :fill_char]

  defimpl Drawing do
    def parse(_, _), do: {:error, :invalid_drawing}

    def apply(%{start_point: %{x: x, y: y}}, %{size_fixed: true, width: width, height: height})
        when width <= x or height <= y,
        do: {:error, :out_of_range}

    def apply(
          %{start_point: %{x: x, y: y}, width: rectangle_width, height: rectangle_height},
          %{size_fixed: true, width: field_width, height: field_height}
        )
        when field_width <= x + rectangle_width or field_height <= y + rectangle_height,
        do: {:error, :out_of_range}

    def apply(rectangle, field) do
      {:ok, apply_rectangle_to_field(field, rectangle)}
    end

    defp apply_rectangle_to_field(field, rectangle) do
      drawing = build_rectangle_drawing(rectangle)

      {updated_field, history} =
        Enum.reduce(drawing, {field, []}, fn
          nil, {updated_field, history} ->
            {updated_field, history}

          {k, v}, {updated_field, history} ->
            current_char = field.body[k]

            if current_char == v do
              {updated_field, history}
            else
              body = updated_field.body

              {
                %{
                  updated_field
                  | body: put_in(body[k], v),
                    width: max(updated_field.width || 0, elem(k, 0) + 1),
                    height: max(updated_field.height || 0, elem(k, 1) + 1)
                },
                [{k, {current_char, v}} | history]
              }
            end
        end)

      {updated_field, Map.new(history)}
    end

    defp build_rectangle_drawing(rectangle) do
      for x <- rectangle.start_point.x..(rectangle.start_point.x + rectangle.width - 1),
          y <- rectangle.start_point.y..(rectangle.start_point.y + rectangle.height - 1) do
        if x in [rectangle.start_point.x, rectangle.start_point.x + rectangle.width - 1] or
             y in [rectangle.start_point.y, rectangle.start_point.y + rectangle.height - 1] do
          {{x, y}, rectangle.outline_char || rectangle.fill_char}
        else
          {{x, y}, rectangle.fill_char}
        end
      end
    end
  end
end
