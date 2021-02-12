defmodule Canvas.Fields.Draw do
  @moduledoc """
  The Draw context.
  """

  import Ecto.Query, warn: false
  alias Canvas.Repo

  alias Canvas.Fields.{Field, History}

  defmodule Coordinate do
    @type t :: %__MODULE__{
          required(:x) => non_neg_integer(),
          required(:y) => non_neg_integer()
        }

   defstruct [:x, :y]
  end

  defmodule Rectangle do
    @type t :: %__MODULE__{
                required(:start_point) => Coordinate.t(),
                required(:width) => pos_integer(),
                required(:height) => pos_integer(),
                optional(:outline_char) => string(),
                optional(:fill_char) => string()
              }

    defstruct [:start_point, :width, :height, :outline_char, :fill_char]

    defprotocol Drawing do
      def parse(data)
    end

    defimpl Drawing, for: Map do
      def parse(%{outline_char: nil, fill_char: nil}) do

      end
      def parse(%{start_point: %{x: x, y: y} = start_point, width: width, height: height} = map)
        when is_integer(x) and x >= 0
             and is_integer(y) and y >= 0
             and is_integer(width) and width > 0
             and is_integer(height) and height > 0 do
        if
        struct(Drawing, map)
      end
    end
  end

  defmodule FloodFill do
    @type t :: %__MODULE__{
                 required(:start_point) => start_point(),
                 optional(:fill_char) => string()
               }

    defstruct [:start_point, :fill_char]
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

  def apply_flood_fill_to_field(field, flood_fill, start_point_char) do
    body = field.body

    apply_flood_fill_to_field(
      %{
        field
        | body: put_in(body[{flood_fill.start_point.x, flood_fill.start_point.y}], flood_fill.fill_char)
      },
      flood_fill,
      {flood_fill.start_point.x, flood_fill.start_point.y},
      start_point_char,
      [
        {{flood_fill.start_point.x, flood_fill.start_point.y},
         {body[{flood_fill.start_point.x, flood_fill.start_point.y}], flood_fill.fill_char}}
      ],
      0,
      [{flood_fill.start_point.x, flood_fill.start_point.y}]
    )
  end

  def apply_flood_fill_to_field(
         field,
         flood_fill,
         {x, y},
         start_point_char,
         history,
         depth,
         depth_history
       ) do
    body = field.body

    cond do
      body[{x, y - 1}] == start_point_char and y - 1 >= 0 and {x, y - 1} not in history ->
        apply_flood_fill_to_field(
          %{field | body: put_in(body[{x, y - 1}], flood_fill.fill_char)},
          flood_fill,
          {x, y - 1},
          start_point_char,
          [{{x, y - 1}, {body[{x, y - 1}], flood_fill.fill_char}} | history],
          depth + 1,
          [{x, y - 1} | depth_history]
        )

      body[{x + 1, y}] == start_point_char and x + 1 <= field.width and {x + 1, y} not in history ->
        apply_flood_fill_to_field(
          %{field | body: put_in(body[{x + 1, y}], flood_fill.fill_char)},
          flood_fill,
          {x + 1, y},
          start_point_char,
          [{{x + 1, y}, {body[{x + 1, y}], flood_fill.fill_char}} | history],
          depth + 1,
          [{x + 1, y} | depth_history]
        )

      body[{x, y + 1}] == start_point_char and y + 1 <= field.height and {x, y + 1} not in history ->
        apply_flood_fill_to_field(
          %{field | body: put_in(body[{x, y + 1}], flood_fill.fill_char)},
          flood_fill,
          {x, y + 1},
          start_point_char,
          [{{x, y + 1}, {body[{x, y + 1}], flood_fill.fill_char}} | history],
          depth + 1,
          [{x, y + 1} | depth_history]
        )

      body[{x - 1, y}] == start_point_char and x - 1 >= 0 and {x - 1, y} not in history ->
        apply_flood_fill_to_field(
          %{field | body: put_in(body[{x - 1, y}], flood_fill.fill_char)},
          flood_fill,
          {x - 1, y},
          start_point_char,
          [{{x - 1, y}, {body[{x - 1, y}], flood_fill.fill_char}} | history],
          depth + 1,
          [{x - 1, y} | depth_history]
        )

      depth > 1 ->
        apply_flood_fill_to_field(
          field,
          flood_fill,
          Enum.at(depth_history, 1),
          start_point_char,
          history,
          depth - 1,
          tl(depth_history)
        )

      true ->
        {field, Map.new(history)}
    end
  end
end
