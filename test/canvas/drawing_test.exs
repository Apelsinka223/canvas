defmodule Canvas.DrawingTest do
  use Canvas.DataCase
  alias Canvas.Drawing
  alias Canvas.Drawing.{Rectangle, FloodFill}
  alias Canvas.Fields.Field

  defp print(field) do
    for y <- 0..(field.height - 1),
        x <- 0..(field.width - 1),
        reduce: "" do
      acc ->
        acc <> if(x == 0 and y != 0, do: "\n", else: "") <> (field.body[{x, y}] || " ")
    end
  end

  describe "fixtures" do
    #
    #
    #   @@@@@
    #   @XXX@  XXXXXXXXXXXXXX
    #   @@@@@  XOOOOOOOOOOOOX
    #          XOOOOOOOOOOOOX
    #          XOOOOOOOOOOOOX
    #          XOOOOOOOOOOOOX
    #          XXXXXXXXXXXXXX
    test "fixture 1" do
      field = %Field{body: %{}, size_fixed: false}

      {:ok, {field, _}} =
        Drawing.apply(
          %Rectangle{
            start_point: %{x: 3, y: 2},
            width: 5,
            height: 3,
            outline_char: "@",
            fill_char: "X"
          },
          field
        )

      {:ok, {field, _}} =
        Drawing.apply(
          %Rectangle{
            start_point: %{x: 10, y: 3},
            width: 14,
            height: 6,
            outline_char: "X",
            fill_char: "O"
          },
          field
        )

      assert field.width == 24
      assert field.height == 9
      assert print(field) == File.read!(Path.join(File.cwd!(), "test/canvas/fixtures/1.txt"))
    end

    #              .......
    #              .......
    #              .......
    # OOOOOOOO      .......
    # O      O      .......
    # O    XXXXX    .......
    # OOOOOXXXXX
    #     XXXXX
    test "fixture 2" do
      field = %Field{body: %{}, size_fixed: false}

      {:ok, {field, _}} =
        Drawing.apply(
          %Rectangle{
            start_point: %{x: 14, y: 0},
            width: 7,
            height: 6,
            outline_char: nil,
            fill_char: "."
          },
          field
        )

      {:ok, {field, _}} =
        Drawing.apply(
          %Rectangle{
            start_point: %{x: 0, y: 3},
            width: 8,
            height: 4,
            outline_char: "O",
            fill_char: nil
          },
          field
        )

      {:ok, {field, _}} =
        Drawing.apply(
          %Rectangle{
            start_point: %{x: 5, y: 5},
            width: 5,
            height: 3,
            outline_char: "X",
            fill_char: "X"
          },
          field
        )

      assert field.width == 21
      assert field.height == 8
      assert print(field) == File.read!(Path.join(File.cwd!(), "test/canvas/fixtures/2.txt"))
    end

    # --------------.......
    # --------------.......
    # --------------.......
    # OOOOOOOO------.......
    # O      O------.......
    # O    XXXXX----.......
    # OOOOOXXXXX-----------
    #     XXXXX-----------
    test "fixture 3" do
      field = %Field{body: %{}, size_fixed: false}

      {:ok, {field, _}} =
        Drawing.apply(
          %Rectangle{
            start_point: %{x: 14, y: 0},
            width: 7,
            height: 6,
            outline_char: nil,
            fill_char: "."
          },
          field
        )

      {:ok, {field, _}} =
        Drawing.apply(
          %Rectangle{
            start_point: %{x: 0, y: 3},
            width: 8,
            height: 4,
            outline_char: "O",
            fill_char: nil
          },
          field
        )

      {:ok, {field, _}} =
        Drawing.apply(
          %Rectangle{
            start_point: %{x: 5, y: 5},
            width: 5,
            height: 3,
            outline_char: "X",
            fill_char: "X"
          },
          field
        )

      {:ok, {field, _}} =
        Drawing.apply(
          %FloodFill{
            start_point: %{x: 0, y: 0},
            fill_char: "-"
          },
          field
        )

      assert field.width == 21
      assert field.height == 8
      assert print(field) == File.read!(Path.join(File.cwd!(), "test/canvas/fixtures/3.txt"))
    end
  end
end
