defmodule Canvas.EctoTypes.FieldHistoryChanges do
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

  def cast(body) do
    case Map.keys(body) do
      [] ->
        {:ok, %{}}

      [k | _] when is_binary(k) ->
        {:ok, decode_body(body)}

      _ ->
        {:ok, body}
    end
  end

  def load(nil) do
    {:ok, nil}
  end

  def load(body) do
    case decode_body(body) do
      :error ->
        :error

      body ->
        {:ok, body}
    end
  end

  def dump(nil) do
    {:ok, nil}
  end

  def dump(body) when is_binary(body), do: {:ok, body}

  def dump(body) do
    case Map.keys(body) do
      [] ->
        {:ok, %{}}

      _ ->
        {:ok, encode_body(body)}
    end
  end

  defp encode_body(body) do
    string =
      body
      |> Enum.map(fn {{x, y}, {old_char, new_char}} ->
        "\"{#{x},#{y}}\": \"{#{old_char || "null"},#{new_char}}\""
      end)
      |> Enum.join(",")

    "{#{string}}"
  end

  defp decode_body(body) do
    body
    |> Jason.decode!()
    |> Enum.reduce_while([], fn {coord, diff}, acc ->
      with coord = String.trim_leading(coord, "{"),
           coord = String.trim_trailing(coord, "}"),
           [x, y] <- String.split(coord, ","),
           {x, _} <- Integer.parse(x),
           {y, _} <- Integer.parse(y),
           diff = String.trim_leading(diff, "{"),
           diff = String.trim_trailing(diff, "}"),
           [old_char, new_char] <- String.split(diff, ",") do
        {:cont, [{{x, y}, {decode_char(old_char), decode_char(new_char)}} | acc]}
      else
        _ ->
          {:halt, :error}
      end
    end)
    |> case do
      :error ->
        :error

      list ->
        Map.new(list)
    end
  end

  defp decode_char("null"), do: nil
  defp decode_char(char), do: char
end
