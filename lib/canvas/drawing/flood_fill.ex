defmodule Canvas.Drawing.Rectangle do
  @moduledoc """
  The Draw context.
  """

  import Ecto.Query, warn: false
  alias Canvas.{Repo, Drawing}

  defmodule Rectangle do
    @type t :: %__MODULE__{
                required(:start_point) => Coordinate.t(),
                required(:width) => pos_integer(),
                required(:height) => pos_integer(),
                optional(:outline_char) => string(),
                optional(:fill_char) => string()
              }

    defstruct [:start_point, :width, :height, :outline_char, :fill_char]


    defimpl Drawing do
      def apply(field, rectangle) do
        apply_rectangle_to_field(field, rectangle)
      end
    end
  end

  def apply_rectangle_to_field(field, rectangle) do
    drawing = build_rectangle_drawing(rectangle)

    {updated_field, history} =
      Enum.reduce(drawing, {field, []}, fn {k, v}, {updated_field, history} ->
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
        {{x, y}, rectangle[:outline_char] || rectangle[:fill_char] || " "}
      else
        {{x, y}, rectangle[:fill_char] || " "}
      end
    end
  end
end
