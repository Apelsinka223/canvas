defmodule Canvas.EctoTypes.FieldBody do
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
      |> Enum.map(fn {{x, y}, char} ->
        "\"{#{x},#{y}}\": \"#{char}\""
      end)
      |> Enum.join(",")

    "{#{string}}"
  end

  defp decode_body(%{} = body), do: body
  defp decode_body(body) do
    body
    |> Jason.decode!()
    |> Enum.reduce_while([], fn {coord, char}, acc ->
     with coord = String.trim_leading(coord, "{"),
          coord = String.trim_trailing(coord, "}"),
          [x, y] <- String.split(coord, ",") do
        {:cont, [{{x, y}, char} | acc]}
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
end
