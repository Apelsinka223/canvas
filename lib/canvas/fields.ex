defmodule Canvas.Fields do
  @moduledoc """
  The Fields context.
  """

  import Ecto.Query, warn: false
  alias Canvas.{Repo, Drawing}
  alias Canvas.Fields.{Field, History}

  @type start_point :: %{
          required(:x) => pos_integer(),
          required(:y) => pos_integer()
        }

  @type rectangle :: %{
          required(:start_point) => start_point(),
          required(:width) => pos_integer(),
          required(:height) => pos_integer(),
          optional(:outline_char) => String.t(),
          optional(:fill_char) => String.t()
        }

  @type flood_fill :: %{
          required(:start_point) => start_point(),
          optional(:fill_char) => String.t()
        }

  @doc """
  Returns the list of fields.

  ## Examples

      iex> list_fields()
      [%Field{}, ...]

  """
  def list_fields do
    Field
    |> order_by(desc: :inserted_at)
    |> Repo.all()
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

  @spec add_rectangle(field :: Field.t() | any(), rectangle :: rectangle()) ::
          {:ok, Field.t()} | {:error, term()}
  def add_rectangle(%Field{} = field, rectangle) do
    Repo.transaction(fn ->
      with {:ok, rectangle} <- Drawing.parse(rectangle, :rectangle),
           {:ok, {updated_field, history}} <- Drawing.apply(rectangle, field),
           updated_field_params = Map.take(updated_field, [:body, :height, :width]),
           {:ok, update_field} <- update_field(field, updated_field_params),
           {:ok, _} <- create_history(%{changes: history, field_id: field.id}) do
        update_field
      else
        {:error, reason} ->
          Repo.rollback(reason)
      end
    end)
  end

  def add_rectangle(_, _), do: {:error, :invalid_field}

  @spec add_flood_fill(field :: Field.t() | any(), flood_fill :: flood_fill()) ::
          {:ok, Field.t()} | {:error, term()}
  def add_flood_fill(%Field{body: body, size_fixed: false} = field, _flood_fill)
      when map_size(body) == 0,
      do: {:ok, field}

  def add_flood_fill(
        %Field{} = field,
        %{start_point: %{x: x, y: y}, fill_char: fill_char} = flood_fill
      ) do
    Repo.transaction(fn ->
      with start_point_char = field.body[{x, y}],
           false <- start_point_char == fill_char,
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

  def add_flood_fill(%Field{}, _), do: {:error, :invalid_flood_fill}
  def add_flood_fill(_, _), do: {:error, :invalid_field}

  def print(%Field{} = field) do
    for y <- 0..(field.height - 1),
        x <- 0..(field.width - 1),
        reduce: "" do
      acc ->
        acc <> if(x == 0 and y != 0, do: "\n", else: "") <> (field.body[{x, y}] || " ")
    end
  end
end
