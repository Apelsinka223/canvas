defmodule Canvas.Shape.Rectangle do
  @moduledoc """
  The Rectangle context.
  Implements Shapes behaviour for rectangles.
  """

  import Ecto.Query, warn: false
  alias Canvas.Shape.Rectangle
  alias Canvas.Fields.{Field, Coordinate}

  @behaviour Canvas.Shape.Behaviour

  @type t :: %__MODULE__{
          start_point: Coordinate.t(),
          width: pos_integer(),
          height: pos_integer(),
          outline_char: String.t(),
          fill_char: String.t()
        }

  @type rectangle :: %{
          required(:start_point) => Coordinate.coordinate(),
          required(:width) => pos_integer(),
          required(:height) => pos_integer(),
          optional(:outline_char) => String.t(),
          optional(:fill_char) => String.t()
        }

  defstruct [:start_point, :width, :height, :outline_char, :fill_char]

  @spec build(rectangle()) :: {:ok, __MODULE__.t()} | {:error, term()}
  def build(%{start_point: %{x: x, y: y}, width: width, height: height} = rectangle) do
    with true <- is_start_point_valid?(x, y),
         true <- is_size_valid?(width, height),
         true <- is_char_valid?(rectangle) do
      {:ok, struct(Rectangle, %{rectangle | start_point: struct(Coordinate, %{x: x, y: y})})}
    else
      false ->
        {:error, :invalid_shape}
    end
  end

  defp is_start_point_valid?(x, y) do
    is_integer(x) and x >= 0 and is_integer(y) and y >= 0
  end

  defp is_size_valid?(width, height) do
    is_integer(width) and width > 0 and is_integer(height) and height > 0
  end

  defp is_char_valid?(%{outline_char: outline_char}) when is_binary(outline_char), do: true
  defp is_char_valid?(%{fill_char: fill_char}) when is_binary(fill_char), do: true
  defp is_char_valid?(_rectangle), do: false

  @spec calculate_shape_coordinates(Rectangle.t(), Field.t()) :: map()
  def calculate_shape_coordinates(%Rectangle{} = rectangle, %Field{} = field) do
    start_x = start_x(rectangle.start_point.x, field)
    start_y = start_y(rectangle.start_point.y, field)
    end_x = end_x(rectangle.start_point.x + rectangle.width - 1, field)
    end_y = end_y(rectangle.start_point.y + rectangle.height - 1, field)

    for x <- start_x..end_x//1,
        y <- start_y..end_y//1 do
      if is_outline?(x, y, rectangle) do
        {{x, y}, rectangle.outline_char || rectangle.fill_char}
      else
        {{x, y}, rectangle.fill_char}
      end
    end
  end

  defp start_x(x, %{size_fixed: true}), do: max(x, 0)
  defp start_x(x, _), do: x

  defp start_y(y, %{size_fixed: true}), do: max(y, 0)
  defp start_y(y, _), do: y

  defp end_x(x, %{size_fixed: true, width: width}), do: min(x, width - 1)
  defp end_x(x, _), do: x

  defp end_y(y, %{size_fixed: true, height: height}), do: min(y, height - 1)
  defp end_y(y, _), do: y

  defp is_outline?(x, y, rectangle) do
    x in [rectangle.start_point.x, rectangle.start_point.x + rectangle.width - 1] or
      y in [rectangle.start_point.y, rectangle.start_point.y + rectangle.height - 1]
  end
end
