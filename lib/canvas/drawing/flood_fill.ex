defmodule Canvas.Drawing.FloodFill do
  @moduledoc """
  The Draw context.
  """

  import Ecto.Query, warn: false
  alias Canvas.{Repo, Drawing}
  alias Canvas.Drawing.Coordinate

  @type t :: %__MODULE__{
          start_point: Coordinate.t(),
          fill_char: string()
        }

  defstruct [:start_point, :fill_char]

  defimpl Drawing do
    def parse(_, _), do: {:error, :invalid_drawing}

    def apply(flood_fill, field) do
      {:ok, apply_flood_fill_to_field(field, flood_fill)}
    end

    defp apply_flood_fill_to_field(field, flood_fill) do
      body = field.body
      start_point_char = body[{flood_fill.start_point.x, flood_fill.start_point.y}]

      apply_flood_fill_to_field(
        %{
          field
          | body:
              put_in(
                body[{flood_fill.start_point.x, flood_fill.start_point.y}],
                flood_fill.fill_char
              )
        },
        flood_fill,
        {flood_fill.start_point.x, flood_fill.start_point.y},
        start_point_char,
        [
          {{flood_fill.start_point.x, flood_fill.start_point.y},
           {start_point_char, flood_fill.fill_char}}
        ],
        0,
        [{flood_fill.start_point.x, flood_fill.start_point.y}]
      )
    end

    defp apply_flood_fill_to_field(
           field,
           flood_fill,
           {x, y},
           start_point_char,
           history,
           depth,
           path_history
         ) do
      body = field.body

      cond do
        # up
        body[{x, y - 1}] == start_point_char and y - 1 >= 0 and {x, y - 1} not in history ->
          apply_flood_fill_to_field(
            %{field | body: put_in(body[{x, y - 1}], flood_fill.fill_char)},
            flood_fill,
            {x, y - 1},
            start_point_char,
            [{{x, y - 1}, {body[{x, y - 1}], flood_fill.fill_char}} | history],
            depth + 1,
            [{x, y - 1} | path_history]
          )

        # right
        body[{x + 1, y}] == start_point_char and x + 1 <= field.width - 1 and
            {x + 1, y} not in history ->
          apply_flood_fill_to_field(
            %{field | body: put_in(body[{x + 1, y}], flood_fill.fill_char)},
            flood_fill,
            {x + 1, y},
            start_point_char,
            [{{x + 1, y}, {body[{x + 1, y}], flood_fill.fill_char}} | history],
            depth + 1,
            [{x + 1, y} | path_history]
          )

        # down
        body[{x, y + 1}] == start_point_char and y + 1 <= field.height - 1 and
            {x, y + 1} not in history ->
          apply_flood_fill_to_field(
            %{field | body: put_in(body[{x, y + 1}], flood_fill.fill_char)},
            flood_fill,
            {x, y + 1},
            start_point_char,
            [{{x, y + 1}, {body[{x, y + 1}], flood_fill.fill_char}} | history],
            depth + 1,
            [{x, y + 1} | path_history]
          )

        # left
        body[{x - 1, y}] == start_point_char and x - 1 >= 0 and {x - 1, y} not in history ->
          apply_flood_fill_to_field(
            %{field | body: put_in(body[{x - 1, y}], flood_fill.fill_char)},
            flood_fill,
            {x - 1, y},
            start_point_char,
            [{{x - 1, y}, {body[{x - 1, y}], flood_fill.fill_char}} | history],
            depth + 1,
            [{x - 1, y} | path_history]
          )

        # backward for search of new path
        depth > 1 ->
          apply_flood_fill_to_field(
            field,
            flood_fill,
            Enum.at(path_history, 1),
            start_point_char,
            history,
            depth - 1,
            tl(path_history)
          )

        # end
        true ->
          {field, Map.new(history)}
      end
    end
  end
end
