defmodule Canvas.Shape.RectangleTest do
  use Canvas.DataCase
  alias Canvas.Shape.Rectangle

  @valid_rectangle_params %{
    width: 10,
    height: 20,
    start_point: %{x: 0, y: 0},
    outline_char: "x",
    fill_char: "-"
  }

  describe "build/2" do
    test "with correct params, return Rectangle.t()" do
      assert {
               :ok,
               %Rectangle{
                 width: 10,
                 height: 20,
                 start_point: %{x: 0, y: 0},
                 outline_char: "x",
                 fill_char: "-"
               }
             } = Rectangle.build(@valid_rectangle_params)
    end

    test "with incorrect params type, return error" do
      assert {:error, :invalid_shape} = Rectangle.build(%{@valid_rectangle_params | width: "10"})

      assert {:error, :invalid_shape} = Rectangle.build(%{@valid_rectangle_params | width: -10})

      assert {:error, :invalid_shape} = Rectangle.build(%{@valid_rectangle_params | height: "10"})

      assert {:error, :invalid_shape} = Rectangle.build(%{@valid_rectangle_params | height: -10})

      assert {:error, :invalid_shape} =
               Rectangle.build(%{@valid_rectangle_params | start_point: %{x: "0", y: 0}})

      assert {:error, :invalid_shape} =
               Rectangle.build(%{@valid_rectangle_params | start_point: %{x: -10, y: 0}})

      assert {:error, :invalid_shape} =
               Rectangle.build(%{@valid_rectangle_params | start_point: %{x: 0, y: "0"}})

      assert {:error, :invalid_shape} =
               Rectangle.build(%{@valid_rectangle_params | start_point: %{x: 0, y: -10}})

      assert {:error, :invalid_shape} =
               Rectangle.build(%{@valid_rectangle_params | fill_char: nil, outline_char: 0})

      assert {:error, :invalid_shape} =
               Rectangle.build(%{@valid_rectangle_params | outline_char: nil, fill_char: 0})
    end

    test "when both outline_char and fill_char are nil, return error" do
      assert {:error, :invalid_shape} =
               Rectangle.build(%{@valid_rectangle_params | fill_char: nil, outline_char: nil})
    end

    test "when one of outline_char and fill_char is nil, return Rectangle.t()" do
      assert {:ok, %Rectangle{}} = Rectangle.build(%{@valid_rectangle_params | fill_char: nil})

      assert {:ok, %Rectangle{}} = Rectangle.build(%{@valid_rectangle_params | outline_char: nil})
    end
  end
end
