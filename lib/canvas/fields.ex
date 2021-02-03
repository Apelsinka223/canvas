defmodule Canvas.Fields do
  @moduledoc """
  The Fields context.
  """

  import Ecto.Query, warn: false
  alias Canvas.Repo

  alias Canvas.Fields.{Field, History}

  @type start_point :: %{
          required(:x) => pos_integer(),
          required(:y) => pos_integer()
        }

  @type rectangle :: %{
          required(:start_point) => start_point(),
          required(:width) => pos_integer(),
          required(:height) => pos_integer(),
          optional(:outline_char) => string(),
          optional(:fill_char) => string()
        }

  @type flood_fill :: %{
          required(:start_point) => start_point(),
          optional(:fill_char) => string()
        }

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

  ## Examples

      iex> get_field(123)
      {:ok, %Field{}}

      iex> get_field(456)
      {:error, :field_not_found}

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
  Returns the list of historys.

  ## Examples

      iex> list_historys()
      [%History{}, ...]

  """
  def list_historys do
    Repo.all(History)
  end

  @doc """
  Gets a single history.

  ## Examples

      iex> get_history(123)
      {:ok, %History{}}

      iex> get_history(456)
      {:error, :history_not_found}

  """
  def get_history(id) do
    case Repo.get(History, id) do
      nil ->
        {:error, :history_not_found}

      history ->
        {:ok, history}
    end
  end

  @doc """
  Creates a history.

  ## Examples

      iex> create_history(%{history: value})
      {:ok, %History{}}

      iex> create_history(%{history: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_history(attrs \\ %{}) do
    %History{}
    |> History.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a history.

  ## Examples

      iex> update_history(history, %{history: new_value})
      {:ok, %History{}}

      iex> update_history(history, %{history: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_history(%History{} = history, attrs) do
    history
    |> History.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a history.

  ## Examples

      iex> delete_history(history)
      {:ok, %History{}}

      iex> delete_history(history)
      {:error, %Ecto.Changeset{}}

  """
  def delete_history(%History{} = history) do
    Repo.delete(history)
  end

  def add_rectangle(%Field{} = field, object) do
    Repo.transaction(fn ->
      with :ok <- check_rectangle(object),
           drawing = build_rectangle_drawing(object),
           {updated_field, history} = apply_rectangle_to_field(field, drawing),
           {:ok, _} <- update_field(field, Map.take(updated_field, [:body, :height, :width])),
           {:ok, _} <- create_history(%{changes: history, field_id: field.id}) do
        field
      else
        {:error, reason} ->
          Repo.rollback(reason)
      end
    end)
  end
  def add_rectangle(_, _), do: {:error, :field_not_found}

  defp check_rectangle(%{outline_char: nil, fill_char: nil}), do: {:error, :invalid_rectangle}
  defp check_rectangle(_), do: :ok

  defp build_rectangle_drawing(drawing) do
    for x <- drawing.start_point.x..(drawing.start_point.x + drawing.width - 1),
        y <- drawing.start_point.y..(drawing.start_point.y + drawing.height - 1) do
      if x in [drawing.start_point.x, drawing.start_point.x + drawing.width - 1] or
           y in [drawing.start_point.y, drawing.start_point.y + drawing.height - 1] do
        {{x, y}, drawing[:outline_char] || drawing[:fill_char] || " "}
      else
        {{x, y}, drawing[:fill_char] || " "}
      end
    end
  end

  defp apply_rectangle_to_field(field, drawing) do
    {updated_field, history} =
      Enum.reduce(drawing, {field, []}, fn {k, v}, {updated_field, history} ->
        current_char = field.body[k]

        if current_char == v do
          {updated_field, history}
        else
          body = updated_field.body

          {
            %{
              updated_field |
              body: put_in(body[k], v),
              width: max(updated_field.width || 0, elem(k, 0) + 1),
              height: max(updated_field.height || 0, elem(k, 1) + 1)
            },
            [{k, {current_char, v}} | history]
          }
        end
      end)

    {updated_field, Map.new(history)}
  end

  def add_flood_fill(%Field{} = field, drawing) do
    with start_point_char = field.body[{drawing.start_point.x, drawing.start_point.y}],
         false <- start_point_char == drawing.fill_char,
         {updated_field, history} = apply_drawing_flood_fill_to_field(field, drawing, start_point_char),
         {:ok, _} <- update_field(field, Map.take(updated_field, [:body, :height, :width])),
         {:ok, _} <- create_history(%{changes: history, field_id: field.id}) do
      {:ok, field}
    else
      true ->
        {:ok, field}
    end
  end
  def add_flood_fill(_, _), do: {:error, :field_not_found}

  defp apply_drawing_flood_fill_to_field(field, drawing, start_point_char) do
    body = field.body

    apply_drawing_flood_fill_to_field(
      %{
        field
        | body: put_in(body[{drawing.start_point.x, drawing.start_point.y}], drawing.fill_char)
      },
      drawing,
      {drawing.start_point.x, drawing.start_point.y},
      start_point_char,
      [{{drawing.start_point.x, drawing.start_point.y}, {body[{drawing.start_point.x, drawing.start_point.y}], drawing.fill_char}}],
      0,
      [{drawing.start_point.x, drawing.start_point.y}]
    )
  end

  defp apply_drawing_flood_fill_to_field(
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
        apply_drawing_flood_fill_to_field(
          %{field | body: put_in(body[{x, y - 1}], drawing.fill_char)},
          drawing,
          {x, y - 1},
          start_point_char,
          [{{x, y - 1}, {body[{x, y - 1}], drawing.fill_char}} | history],
          depth + 1,
          [{x, y - 1} | depth_history]
        )

      body[{x + 1, y}] == start_point_char and x + 1 <= field.width and {x + 1, y} not in history ->
        apply_drawing_flood_fill_to_field(
          %{field | body: put_in(body[{x + 1, y}], drawing.fill_char)},
          drawing,
          {x + 1, y},
          start_point_char,
          [{{x + 1, y}, {body[{x + 1, y}], drawing.fill_char}} | history],
          depth + 1,
          [{x + 1, y} | depth_history]
        )

      body[{x, y + 1}] == start_point_char and y + 1 <= field.height and {x, y + 1} not in history ->
        apply_drawing_flood_fill_to_field(
          %{field | body: put_in(body[{x, y + 1}], drawing.fill_char)},
          drawing,
          {x, y + 1},
          start_point_char,
          [{{x, y + 1}, {body[{x, y + 1}], drawing.fill_char}} | history],
          depth + 1,
          [{x, y + 1} | depth_history]
        )

      body[{x - 1, y}] == start_point_char and x - 1 >= 0 and {x - 1, y} not in history ->
        apply_drawing_flood_fill_to_field(
          %{field | body: put_in(body[{x - 1, y}], drawing.fill_char)},
          drawing,
          {x - 1, y},
          start_point_char,
          [{{x - 1, y}, {body[{x - 1, y}], drawing.fill_char}} | history],
          depth + 1,
          [{x - 1, y} | depth_history]
        )

      depth > 1 ->
        apply_drawing_flood_fill_to_field(
          field,
          drawing,
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

  def print(field) do
    for y <- 0..field.height - 1,
        x <- 0..field.width - 1 do
      if x == 0, do: IO.write("\n")
      IO.write(field.body[{x, y}] || " ")
    end
  end
end
