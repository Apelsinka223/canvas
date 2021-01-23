defmodule Canvas.Fields do
  @moduledoc """
  The Fields context.
  """

  import Ecto.Query, warn: false
  alias Canvas.Repo

  alias Canvas.Fields.Field

  @doc """
  Returns the list of fields.

  ## Examples

      iex> list_fields()
      [%Field{}, ...]

  """
  def list_fields do
    Repo.all(Field)
  end

  @doc """
  Gets a single field.

  Raises `Ecto.NoResultsError` if the Field does not exist.

  ## Examples

      iex> get_field!(123)
      %Field{}

      iex> get_field!(456)
      ** (Ecto.NoResultsError)

  """
  def get_field(id) do
    case Repo.get(Field, id) do
      nil ->
        {:error, :field_not_found}

      field ->
        {:ok, field}
    end
  end

  @doc """
  Creates a field.

  ## Examples

      iex> create_field(%{field: value})
      {:ok, %Field{}}

      iex> create_field(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_field(attrs \\ %{}) do
    %Field{}
    |> Field.create_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a field.

  ## Examples

      iex> update_field(field, %{field: new_value})
      {:ok, %Field{}}

      iex> update_field(field, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_field(%Field{} = field, attrs) do
    field
    |> Field.update_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a field.

  ## Examples

      iex> delete_field(field)
      {:ok, %Field{}}

      iex> delete_field(field)
      {:error, %Ecto.Changeset{}}

  """
  def delete_field(%Field{} = field) do
    Repo.delete(field)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking field changes.

  ## Examples

      iex> change_field(field)
      %Ecto.Changeset{data: %Field{}}

  """
  def change_field(%Field{} = field, attrs \\ %{}) do
    Field.changeset(field, attrs)
  end

  def apply_drawing(field, %{width: _} = drawing) do
    drawing_field =
      for x <- drawing.start_point.x..(drawing.start_point.x + drawing.width - 1),
          y <- drawing.start_point.y..(drawing.start_point.y + drawing.height - 1) do
        if x in [drawing.start_point.x, drawing.start_point.x + drawing.width - 1] or
             y in [drawing.start_point.y, drawing.start_point.y + drawing.height - 1] do
          {{x, y}, drawing[:outline_char] || drawing[:fill_char] || " "}
        else
          {{x, y}, drawing[:fill_char] || " "}
        end
      end

    {updated_field, history} =
      Enum.reduce(drawing_field, {field, []}, fn {k, v}, {updated_field, history} ->
        current_char = field.body[k]

        if current_char == v do
          {updated_field, history}
        else
          body = updated_field.body

          {
            %{
              body: put_in(body[k], v),
              max_x: max(updated_field.max_x, elem(k, 0)),
              max_y: max(updated_field.max_y, elem(k, 1))
            },
            [{k, {current_char, v}} | history]
          }
        end
      end)

    updated_field
  end

  def apply_drawing(field, drawing) do
    start_point_char = field.body[{drawing.start_point.x, drawing.start_point.y}]

    if start_point_char == drawing.char do
      field
    else
      body = field.body

      apply_drawing_flood_fill(
        %{
          field
          | body: put_in(body[{drawing.start_point.x, drawing.start_point.y}], drawing.char)
        },
        drawing,
        {drawing.start_point.x, drawing.start_point.y},
        start_point_char,
        [{drawing.start_point.x, drawing.start_point.y}],
        0,
        [{drawing.start_point.x, drawing.start_point.y}]
      )
    end
  end

  defp apply_drawing_flood_fill(
         field,
         drawing,
         {x, y},
         start_point_char,
         history,
         depth,
         depth_history
       ) do
    body = field.body

    cond do
      body[{x, y - 1}] == start_point_char and y - 1 >= 0 and {x, y - 1} not in history ->
        apply_drawing_flood_fill(
          %{field | body: put_in(body[{x, y - 1}], drawing.char)},
          drawing,
          {x, y - 1} |> IO.inspect(),
          start_point_char,
          [{{x, y - 1}, {body[{x, y - 1}], drawing.char}} | history],
          (depth + 1) |> IO.inspect(),
          [{x, y - 1} | depth_history]
        )

      body[{x + 1, y}] == start_point_char and x + 1 <= field.max_x and {x + 1, y} not in history ->
        apply_drawing_flood_fill(
          %{field | body: put_in(body[{x + 1, y}], drawing.char)},
          drawing,
          {x + 1, y} |> IO.inspect(),
          start_point_char,
          [{{x + 1, y}, {body[{x + 1, y}], drawing.char}} | history],
          (depth + 1) |> IO.inspect(),
          [{x + 1, y} | depth_history]
        )

      body[{x, y + 1}] == start_point_char and y + 1 <= field.max_y and {x, y + 1} not in history ->
        apply_drawing_flood_fill(
          %{field | body: put_in(body[{x, y + 1}], drawing.char)},
          drawing,
          {x, y + 1} |> IO.inspect(),
          start_point_char,
          [{{x, y + 1}, {body[{x, y + 1}], drawing.char}} | history],
          (depth + 1) |> IO.inspect(),
          [{x, y + 1} | depth_history]
        )

      body[{x - 1, y}] == start_point_char and x - 1 >= 0 and {x - 1, y} not in history ->
        apply_drawing_flood_fill(
          %{field | body: put_in(body[{x - 1, y}], drawing.char)},
          drawing,
          {x - 1, y} |> IO.inspect(),
          start_point_char,
          [{{x - 1, y}, {body[{x - 1, y}], drawing.char}} | history],
          (depth + 1) |> IO.inspect(),
          [{x - 1, y} | depth_history]
        )

      depth > 1 ->
        apply_drawing_flood_fill(
          field,
          drawing,
          Enum.at(depth_history, 1) |> IO.inspect(),
          start_point_char,
          history,
          depth - 1,
          tl(depth_history)
        )

      true ->
        IO.inspect({x, y})
        IO.inspect(body[{x, y + 1}])
        IO.inspect(body[{x + 1, y}])
        IO.inspect(body[{x, y - 1}])
        IO.inspect(body[{x - 1, y}])
        IO.inspect(field.max_x)
        IO.inspect(field.max_y)
        IO.inspect(history)
        field
    end
  end

  def print(field) do
    for y <- 0..field.max_y,
        x <- 0..field.max_x do
      if x == 0, do: IO.write("\n")
      IO.write(field.body[{x, y}] || " ")
    end
  end
end
