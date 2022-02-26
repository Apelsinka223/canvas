defmodule Canvas.EctoTypes.FieldHistoryChanges do
  @moduledoc """
  Custom type for Field changes history.
  """
  import Canvas.Helpers

  def type, do: :map

  def equal?(nil, nil), do: true
  def equal?(nil, _), do: false
  def equal?(_, nil), do: false

  def equal?(value1, value2) do
    value1 =
      case Map.keys(value1) do
        [] -> %{}
        [k | _] when is_binary(k) -> decode_body(value1)
        _ -> value1
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
      {{x, y}, {old_v, new_v}} ->
        is_valid_coordinate?(x, y) and is_valid_char?(old_v) and is_valid_char?(new_v)

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
  defp is_valid_char?(nil), do: true
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
      |> Enum.map(fn {{x, y}, {old_char, new_char}} ->
        encode_tuple_to_json({x, y}) <>
          ": " <>
          encode_tuple_to_json({encode_nullable_char_to_json(old_char), new_char})
      end)
      |> Enum.join(",")

    "{#{string}}"
  end

  defp decode_body(body) do
    body
    |> Jason.decode!()
    |> Enum.reduce_while([], fn {coordinate, diff}, acc ->
      with {x, y} <- decode_coordinate(coordinate),
           {old_char, new_char} <- decode_json_to_tuple(diff),
           old_char = decode_nullable_char_to_json(old_char),
           new_char = decode_nullable_char_to_json(new_char) do
        {:cont, [{{x, y}, {old_char, new_char}} | acc]}
      else
        _ ->
          {:halt, :error}
      end
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
