defmodule Canvas.Shape do
  @moduledoc """
  Shape context module.
  Responsible for the actions on shapes.
  Uses interface described in the Shapes behaviour.
  """

  alias Canvas.Shape.Rectangle

  @doc """
  Applies a new shape to the field. Validates the passed shape parameters.
  Returns adjusted field and builds history record.

  If no changes were applied (e.g. due to drawing is out of range of the canvas),
  returns only field (without any changes)

  # Parameters

    - field - Field.t() - a current state of the canvas.

    - shape_params - map() - a map of the shape parameters, that used to build a shape struct.
                             Fields list depends on the shape type.

  # Result

    - {:ok, {Field.t(), history :: map()}}} - when passed params are valid, returns an adjusted
      field (but not updated in DB!) and built map for the changes.

    - {:error, term()} - when passed params are invalid, returns an error with error type

  # Examples

    iex> apply(
           %Field{body: %{}, width: 0, height: 0, size_fixed: false},
           %{start_point: {0, 0}, width: 1, height: 2, fill_char: "x"}
         )
    {:ok, {%Field{body: %{{0, 0} => "x", {0, 1} => "x"}, width: 1, height: 2, size_fixed: false}}

    iex> apply(
           %Field{body: %{}, width: 0, height: 0, size_fixed: false},
           %{start_point: {0, 0}, width: -10, height: "x"}
         )
    {:error, :invalid_shape}


    iex> apply(
           %Field{body: %{}, width: 1, height: 2, size_fixed: true},
           %{start_point: {10, 10}, width: 1, height: 2, fill_char: "x"}
         )
    {:ok, %Field{body: %{}, width: 1, height: 2, size_fixed: true}}
  """
  @spec apply(Field.t(), Rectangle.rectangle()) ::
          {:ok, {Field.t(), history :: map()} | Field.t()} | {:error, term()}
  def apply(field, shape_params) do
    with {:ok, shape} <- build(shape_params),
         {field_to_update, history} <- apply_shape_to_field(shape, field) do
      {:ok, {field_to_update, history}}
    else
      nil ->
        {:ok, field}

      error ->
        error
    end
  end

  defp apply_shape_to_field(shape, field) do
    with coordinates = calculate_shape_coordinates(shape, field),
         {field_to_update, history} <- update_field_and_history_by_coordinates(field, coordinates) do
      {field_to_update, history}
    end
  end

  defp update_field_and_history_by_coordinates(field, coordinates) do
    coordinates
    |> Enum.reduce({field, []}, fn
      nil, {updated_field, history} ->
        {updated_field, history}

      {{x, y}, new_char}, {updated_field, history} ->
        current_char = field.body[{x, y}]

        if current_char == new_char do
          {updated_field, history}
        else
          updated_field = update_field_by_coordinate(updated_field, {x, y}, new_char)

          updated_history =
            add_history_record_by_coordinate(history, {x, y}, current_char, new_char)

          {updated_field, updated_history}
        end
    end)
    |> then(fn
      {_, []} ->
        nil

      {updated_field, history} ->
        {updated_field, Map.new(history)}
    end)
  end

  defp update_field_by_coordinate(field, {x, y}, char) do
    field
    |> update_char_by_coordinate({x, y}, char)
    |> maybe_adjust_width(x + 1)
    |> maybe_adjust_height(y + 1)
  end

  defp update_char_by_coordinate(field, {x, y}, char), do: put_in(field.body[{x, y}], char)

  defp maybe_adjust_width(field, new_value),
    do: update_in(field.width, &max(&1 || 0, new_value))

  defp maybe_adjust_height(field, new_value),
    do: update_in(field.height, &max(&1 || 0, new_value))

  defp add_history_record_by_coordinate(history, {x, y}, current_char, new_char),
    do: [{{x, y}, {current_char, new_char}} | history]

  defp build(%{width: _, height: _} = shape_params), do: Rectangle.build(shape_params)
  defp build(_shape_params), do: {:error, :invalid_shape}

  defp calculate_shape_coordinates(%shape_module{} = shape, field),
    do: shape_module.calculate_shape_coordinates(shape, field)
end
