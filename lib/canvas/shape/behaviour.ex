defmodule Canvas.Shape.Behaviour do
  @moduledoc """
  Behaviour of Modules for drawing shapes.
  Responsible for operations with shapes, applied to canvas.
  """

  alias Canvas.Shape.Field

  @doc """
  Validates input and creates a struct for a shape.
  Pattern matches the shape type by input.
  Returns built struct of the shape if params are valid.

  # Parameters

    - shape_params - map() - a map of the shape parameters, that used to build a shape struct.
                             Fields list depends on the shape type.

  # Result

    - {:ok, Shape.t()} - when passed params are valid, returns a struct

    - {:error, term()} - when passed params are invalid, returns an error with error type

  # Examples

    iex> build(%{start_point: {0, 0}, width: 10, height: 2, fill_char: "x"})
    {:ok, %Rectangle{start_point: {0, 0}, width: 10, height: 2}}}

    iex> build(%{start_point: {0, 0}, width: -10, height: "x"})
    {:error, :invalid_shape}
  """
  @callback build(shape_params :: map()) :: {:ok, struct()} | {:error, term()}

  @doc """
  Calculates the coordinates that the shape will occupy on the canvas.
  Returns a map of the coordinates and chars.

  # Parameters

    - shape - struct() - a struct of the shape, the struct type depends on the type of the shape

    - canvas - Field.t() - a current state of the canvas.

  # Result

    - coordinates - map() - a map of the coordinates and chars. E.g.: %{{1, 1} => "x"}

  # Examples

    iex> calculate_shape_coordinates(
           %Rectangle{start_point: {0, 0}, width: 1, height: 2, fill_char: "x"},
           %Field{body: %{}, width: 0, height: 0, size_fixed: false}
         )
    %{{0, 0} => "x", {0, 1} => "x"}
  """
  @callback calculate_shape_coordinates(shape :: struct(), canvas :: Field.t()) :: map()
end
