defmodule Canvas.Fields do
  @moduledoc """
  The Fields context.
  """

  import Ecto.Query, warn: false
  alias Canvas.{Repo, Drawing}
  alias Canvas.Fields.{Field, History}
  alias Canvas.Drawing.{Rectangle, FloodFill}

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

  def add_rectangle(%Field{} = field, rectangle) do
    Repo.transaction(fn ->
      with {:ok, rectangle} <- Drawing.parse(rectangle, :rectangle),
           {:ok, {updated_field, history}} <- Drawing.apply(rectangle, field),
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

  def add_flood_fill(%Field{} = field, flood_fill) do
    Repo.transaction(fn ->
      with start_point_char = field.body[{flood_fill.start_point.x, flood_fill.start_point.y}],
           false <- start_point_char == flood_fill.fill_char,
           {:ok, flood_fill} <- Drawing.parse(flood_fill, :flood_fill),
           {:ok, {updated_field, history}} <- Drawing.apply(flood_fill, field),
           {:ok, _} <- update_field(field, Map.take(updated_field, [:body, :height, :width])),
           {:ok, _} <- create_history(%{changes: history, field_id: field.id}) do
        field
      else
        true ->
          field

        {:error, reason} ->
          Repo.rollback(reason)
      end
    end)
  end

  def add_flood_fill(_, _), do: {:error, :field_not_found}

  @spec
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
      [
        {{drawing.start_point.x, drawing.start_point.y},
         {body[{drawing.start_point.x, drawing.start_point.y}], drawing.fill_char}}
      ],
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
    for y <- 0..(field.height - 1),
        x <- 0..(field.width - 1),
        reduce: "" do
      acc ->
        acc <> (if x == 0 and y != 0, do: "\n", else: "") <> (field.body[{x, y}] || " ")
    end
  end
end
