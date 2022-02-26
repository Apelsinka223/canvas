defmodule Canvas.Helpers do
  @moduledoc """
  Module of the reusable functions.
  """

  def decode_json_to_tuple(json) do
    json
    |> String.trim_leading("{")
    |> String.trim_trailing("}")
    |> String.split(",")
    |> List.to_tuple()
  end

  def encode_tuple_to_json(tuple) do
    string =
      tuple
      |> Tuple.to_list()
      |> Enum.join(",")

    "\"{#{string}}\""
  end

  def encode_nullable_char_to_json(nil), do: "null"
  def encode_nullable_char_to_json(char), do: "\"#{char}\""

  def decode_nullable_char_to_json("null"), do: nil
  def decode_nullable_char_to_json(char), do: char
end
