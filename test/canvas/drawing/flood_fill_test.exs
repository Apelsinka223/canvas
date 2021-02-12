defmodule Canvas.Drawing.RectangleTest do
  use Canvas.DataCase
  alias Canvas.Drawing
  alias Canvas.Drawing.Rectangle

  @valid_rectangle_params  %{
    width: 10,
    height: 20,
    start_point: %{
      x: 0,
      y: 0
    },
    outline_char: "x",
    fill_char: "-"
  }

  describe "parse/2" do
    test "with correct params, return Rectangle.t()" do
      assert {
               :ok,
               %Rectangle{
                 width: 10,
                 height: 20,
                 start_point: %{
                   x: 0,
                   y: 0
                 },
                 outline_char: "x",
                 fill_char: "-"
               }
             } = Drawing.parse(@valid_rectangle_params, :rectangle)
    end

    test "with incorrect params type, return error" do
      assert {:error, :invalid_drawing} =
               Drawing.parse(%{@valid_rectangle_params | width: "10"}, :rectangle)

      assert {:error, :invalid_drawing} =
               Drawing.parse(%{@valid_rectangle_params | width: -10}, :rectangle)

      assert {:error, :invalid_drawing} =
               Drawing.parse(%{@valid_rectangle_params | height: "10"}, :rectangle)

      assert {:error, :invalid_drawing} =
               Drawing.parse(%{@valid_rectangle_params | height: -10}, :rectangle)

      assert {:error, :invalid_drawing} =
               Drawing.parse(%{@valid_rectangle_params | outline_char: 0}, :rectangle)

      assert {:error, :invalid_drawing} =
               Drawing.parse(%{@valid_rectangle_params | fill_char: 0}, :rectangle)
    end

    test "when both outline_char and fill_char are nil, return error" do
      assert {:error, :invalid_drawing} = Drawing.parse(
               %{@valid_rectangle_params | fill_char: nil, outline_char: nil},
               :rectangle
             )
    end

    test "when one of outline_char and fill_char is nil, return Rectangle.t()" do
      assert {:ok, %Rectangle{}} =
               Drawing.parse(%{@valid_rectangle_params | fill_char: nil}, :rectangle)

      assert {:ok, %Rectangle{}} =
               Drawing.parse(%{@valid_rectangle_params | outline_char: nil}, :rectangle)
    end
  end
end
