defmodule Canvas.Fields do
  @moduledoc """
  The Fields context.
  Responsible for canvas related changes.
  """

  import Ecto.Query, warn: false
  alias Canvas.{Repo, Shape}
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
  def list_histories do
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
      with {:ok, {field_to_update, history}} <- Shape.apply(field, rectangle),
           {:ok, updated_field} <-
             update_field(field, %{
               body: field_to_update.body,
               width: field_to_update.width,
               height: field_to_update.height
             }),
           {:ok, _} <- create_history(%{changes: history, field_id: field.id}) do
        updated_field
      else
        {:ok, field} ->
          field

        {:error, reason} ->
          Repo.rollback(reason)
      end
    end)
  end

  def add_rectangle(_, _), do: {:error, :invalid_field}

  def print(%Field{} = field) do
    for y <- 0..(field.height - 1),
        x <- 0..(field.width - 1),
        reduce: "" do
      acc ->
        acc <> maybe_move_caret(x, y) <> print_coordinate(field, x, y)
    end
  end

  defp maybe_move_caret(0 = _x, y) when y != 0, do: "\n"
  defp maybe_move_caret(_x, _y), do: ""

  defp print_coordinate(field, x, y), do: field.body[{x, y}] || " "
end
