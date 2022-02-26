defmodule Canvas.EctoTypes.FieldBody do
  @moduledoc """
  Custom type for Field body.
  """
  import Canvas.Helpers

  def type, do: :map

  def equal?(nil, nil), do: true
  def equal?(nil, _), do: false
  def equal?(_, nil), do: false

  def equal?(value1, value2) do
    value1 =
      case Map.keys(value1) do
        [] ->
          %{}

        [k | _] when is_binary(k) ->
          decode_body(value1)

        _ ->
          value1
      end

    value2 =
      case Map.keys(value2) do
        [] ->
          %{}

        [k | _] when is_binary(k) ->
          decode_body(value2)

        _ ->
          value2
      end

    value1 == value2
  end

  def cast(body) when is_map(body) do
    body
    |> Enum.all?(fn
      {{x, y}, char} ->
        is_valid_coordinate?(x, y) and is_valid_char?(char)

      _ ->
        false
    end)
    |> if do
      {:ok, body}
    else
      :error
    end
  end

  def cast(body) when is_binary(body), do: {:ok, body}

  def cast(body) do
    case decode_body(body) do
      :error -> :error
      body -> {:ok, body}
    end
  end

  defp is_valid_coordinate?(x, y) do
    is_integer(x) and x >= 0 and is_integer(y) and y >= 0
  end

  defp is_valid_char?(<<_::bytes-size(1)>>), do: true
  defp is_valid_char?(_), do: false

  def load(nil), do: {:ok, nil}

  def load(body) do
    case decode_body(body) do
      :error -> :error
      body -> {:ok, body}
    end
  end

  def dump(nil), do: {:ok, nil}
  def dump(body) when is_binary(body), do: {:ok, body}
  def dump(body) when is_map(body) and map_size(body) == 0, do: {:ok, body}

  def dump(body) do
    case encode_body(body) do
      :error -> :error
      body -> {:ok, body}
    end
  end

  defp encode_body(body) do
    string =
      body
      |> Enum.map(fn {{x, y}, char} ->
        encode_tuple_to_json({x, y}) <> ": " <> encode_nullable_char_to_json(char)
      end)
      |> Enum.join(",")

    "{#{string}}"
  end

  defp decode_body(%{} = body), do: body
  defp decode_body("\"{}\""), do: {:ok, %{}}

  defp decode_body(body) do
    body
    |> Jason.decode!()
    |> Enum.reduce_while([], fn
      {coordinate, <<_::bytes-size(1)>> = char}, acc ->
        with {x, y} <- decode_coordinate(coordinate),
             char = decode_nullable_char_to_json(char) do
          {:cont, [{{x, y}, char} | acc]}
        else
          :error -> {:halt, :error}
        end

      _, _ ->
        {:halt, :error}
    end)
    |> case do
      :error -> :error
      list -> Map.new(list)
    end
  end

  defp decode_coordinate(coordinate) do
    with {x, y} <- decode_json_to_tuple(coordinate),
         {x, _} <- Integer.parse(x),
         {y, _} <- Integer.parse(y) do
      {x, y}
    else
      _ ->
        :error
    end
  end
end
