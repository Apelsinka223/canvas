defmodule Canvas.EctoTypes.FieldBody do
  def type, do: :map

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
        %{}

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

  def dump(body) do
    case Map.keys(body) do
      [] ->
        %{}

      [k | _] when is_binary(k) ->
        {:ok, body}

      _ ->
        {:ok, encode_body(body)}
    end
  end

  defp encode_body(body) do
    body
    |> Enum.map(fn {{x, y}, char} -> {"{#{x},#{y}}", char} end)
    |> Map.new()
  end

  defp decode_body(body) do
    body
    |> Enum.reduce_while([], fn {k, v}, acc ->
      k
      |> String.trim_leading("{")
      |> String.trim_trailing("}")
      |> String.split(",")
      |> case do
        [x, y] ->
          {:cont, [{{x, y}, v} | acc]}

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
end
