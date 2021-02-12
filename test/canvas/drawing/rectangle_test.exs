defmodule Canvas.Drawing.RectangleTest do
  use Canvas.DataCase
  alias Canvas.Drawing
  alias Canvas.Drawing.Rectangle
  alias Canvas.Fields.Field

  @valid_rectangle_params %{
    width: 10,
    height: 20,
    start_point: %{x: 0, y: 0},
    outline_char: "x",
    fill_char: "-"
  }

  @valid_rectangle %Rectangle{
    width: 1,
    height: 2,
    start_point: %{x: 0, y: 0},
    outline_char: "x",
    fill_char: "-"
  }

  @valid_field %Field{
    width: 10,
    height: 20,
    body: %{},
    size_fixed: true
  }

  describe "parse/2" do
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
               Drawing.parse(
                 %{@valid_rectangle_params | start_point: %{x: "0", y: 0}},
                 :rectangle
               )

      assert {:error, :invalid_drawing} =
               Drawing.parse(
                 %{@valid_rectangle_params | start_point: %{x: -10, y: 0}},
                 :rectangle
               )

      assert {:error, :invalid_drawing} =
               Drawing.parse(
                 %{@valid_rectangle_params | start_point: %{x: 0, y: "0"}},
                 :rectangle
               )

      assert {:error, :invalid_drawing} =
               Drawing.parse(
                 %{@valid_rectangle_params | start_point: %{x: 0, y: -10}},
                 :rectangle
               )

      assert {:error, :invalid_drawing} =
               Drawing.parse(%{@valid_rectangle_params | outline_char: 0}, :rectangle)

      assert {:error, :invalid_drawing} =
               Drawing.parse(%{@valid_rectangle_params | fill_char: 0}, :rectangle)
    end

    test "when both outline_char and fill_char are nil, return error" do
      assert {:error, :invalid_drawing} =
               Drawing.parse(
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

  describe "apply/2" do
    test "with correct params, return {Field.t(), map()}" do
      assert Drawing.apply(@valid_rectangle, @valid_field) == {
               :ok,
               {
                 %Field{
                   width: 10,
                   height: 20,
                   body: %{{0, 0} => "x", {0, 1} => "x"},
                   size_fixed: true,
                 },
                 %{{0, 0} => {nil, "x"}, {0, 1} => {nil, "x"}}
               }
             }
    end

    test "fill field with different outline and fill chars" do
      assert {
               :ok,
               {
                 %Field{
                   width: 10,
                   height: 20,
                   body: %{
                     {0, 0} => "x",
                     {0, 1} => "x",
                     {1, 0} => "x",
                     {1, 1} => "-",
                     {1, 2} => "x",
                     {2, 0} => "x",
                     {2, 1} => "x",
                     {2, 2} => "x",
                   }
                 },
                 %{
                   {0, 0} => {nil, "x"},
                   {0, 1} => {nil, "x"},
                   {0, 2} => {nil, "x"},
                   {1, 0} => {nil, "x"},
                   {1, 1} => {nil, "-"},
                   {1, 2} => {nil, "x"},
                   {2, 0} => {nil, "x"},
                   {2, 1} => {nil, "x"},
                   {2, 2} => {nil, "x"},
                 }
               }
             } = Drawing.apply(
               %Rectangle{@valid_rectangle | width: 3, height: 3}, @valid_field)
    end

    test "with different start_point" do
      assert {
               :ok,
               {
                 %Field{
                   width: 10,
                   height: 20,
                   body: %{
                     {3, 3} => "x",
                     {3, 4} => "x",
                     {3, 5} => "x",
                     {4, 3} => "x",
                     {4, 4} => "-",
                     {4, 5} => "x",
                     {5, 3} => "x",
                     {5, 4} => "x",
                     {5, 5} => "x",
                   }
                 },
                 %{
                   {3, 3} => {nil, "x"},
                   {3, 4} => {nil, "x"},
                   {3, 5} => {nil, "x"},
                   {4, 3} => {nil, "x"},
                   {4, 4} => {nil, "-"},
                   {4, 5} => {nil, "x"},
                   {5, 3} => {nil, "x"},
                   {5, 4} => {nil, "x"},
                   {5, 5} => {nil, "x"},
                 }
               }
             } = Drawing.apply(
               %Rectangle{@valid_rectangle | width: 3, height: 3, start_point: %{x: 3, y: 3}},
               @valid_field
             )
    end

    test "when field is prefilled with flood_fill" do
      assert Drawing.apply(
               %Rectangle{@valid_rectangle | width: 3, height: 3},
               %Field{
                 width: 5,
                 height: 5,
                 body: %{
                   {0, 0} => "a",
                   {0, 1} => "a",
                   {0, 2} => "a",
                   {0, 3} => "a",
                   {0, 4} => "a",
                   {1, 0} => "a",
                   {1, 1} => "a",
                   {1, 2} => "a",
                   {1, 3} => "a",
                   {1, 4} => "a",
                   {2, 0} => "a",
                   {2, 1} => "a",
                   {2, 2} => "a",
                   {2, 3} => "a",
                   {2, 4} => "a",
                   {3, 0} => "a",
                   {3, 1} => "a",
                   {3, 2} => "a",
                   {3, 3} => "a",
                   {3, 4} => "a",
                   {4, 0} => "a",
                   {4, 1} => "a",
                   {4, 2} => "a",
                   {4, 3} => "a",
                   {4, 4} => "a",
                 },
                 size_fixed: true
               }
             ) == {
               :ok,
               {
                 %Field{
                   width: 5,
                   height: 5,
                   body: %{
                     {0, 0} => "x",
                     {0, 1} => "x",
                     {0, 2} => "x",
                     {0, 3} => "a",
                     {0, 4} => "a",
                     {1, 0} => "x",
                     {1, 1} => "-",
                     {1, 2} => "x",
                     {1, 3} => "a",
                     {1, 4} => "a",
                     {2, 0} => "x",
                     {2, 1} => "x",
                     {2, 2} => "x",
                     {2, 3} => "a",
                     {2, 4} => "a",
                     {3, 0} => "a",
                     {3, 1} => "a",
                     {3, 2} => "a",
                     {3, 3} => "a",
                     {3, 4} => "a",
                     {4, 0} => "a",
                     {4, 1} => "a",
                     {4, 2} => "a",
                     {4, 3} => "a",
                     {4, 4} => "a",
                   },
                   size_fixed: true
                 },
                 %{
                   {0, 0} => {"a", "x"},
                   {0, 1} => {"a", "x"},
                   {0, 2} => {"a", "x"},
                   {1, 0} => {"a", "x"},
                   {1, 1} => {"a", "-"},
                   {1, 2} => {"a", "x"},
                   {2, 0} => {"a", "x"},
                   {2, 1} => {"a", "x"},
                   {2, 2} => {"a", "x"},
                 }
               },
             }
    end

    #.....
    #.....
    #..aaa
    #..aaa
    #..aaa
    test "when field is prefilled with rectangle" do
      assert Drawing.apply(
               %Rectangle{@valid_rectangle | width: 3, height: 3},
               %Field{
                 width: 5,
                 height: 5,
                 body: %{
                   {0, 0} => ".",
                   {0, 1} => ".",
                   {0, 2} => ".",
                   {0, 3} => ".",
                   {0, 4} => ".",
                   {1, 0} => ".",
                   {1, 1} => ".",
                   {1, 2} => ".",
                   {1, 3} => ".",
                   {1, 4} => ".",
                   {2, 0} => ".",
                   {2, 1} => ".",
                   {2, 2} => "a",
                   {2, 3} => "a",
                   {2, 4} => "a",
                   {3, 0} => ".",
                   {3, 1} => ".",
                   {3, 2} => "a",
                   {3, 3} => "a",
                   {3, 4} => "a",
                   {4, 0} => ".",
                   {4, 1} => ".",
                   {4, 2} => "a",
                   {4, 3} => "a",
                   {4, 4} => "a",
                 },
                 size_fixed: true
               }
             ) == {
               :ok,
               {
                 %Field{
                   width: 5,
                   height: 5,
                   body: %{
                     {0, 0} => "x",
                     {0, 1} => "x",
                     {0, 2} => "x",
                     {0, 3} => ".",
                     {0, 4} => ".",
                     {1, 0} => "x",
                     {1, 1} => "-",
                     {1, 2} => "x",
                     {1, 3} => ".",
                     {1, 4} => ".",
                     {2, 0} => "x",
                     {2, 1} => "x",
                     {2, 2} => "x",
                     {2, 3} => "a",
                     {2, 4} => "a",
                     {3, 0} => ".",
                     {3, 1} => ".",
                     {3, 2} => "a",
                     {3, 3} => "a",
                     {3, 4} => "a",
                     {4, 0} => ".",
                     {4, 1} => ".",
                     {4, 2} => "a",
                     {4, 3} => "a",
                     {4, 4} => "a",
                   },
                   size_fixed: true
                 },
                 %{
                   {0, 0} => {".", "x"},
                   {0, 1} => {".", "x"},
                   {0, 2} => {".", "x"},
                   {1, 0} => {".", "x"},
                   {1, 1} => {".", "-"},
                   {1, 2} => {".", "x"},
                   {2, 0} => {".", "x"},
                   {2, 1} => {".", "x"},
                   {2, 2} => {"a", "x"},
                 }
               }
             }
    end

    test "when field size is not fixed and field is empty" do
      assert Drawing.apply(
               @valid_rectangle,
               %Field{
                 width: nil,
                 height: nil,
                 body: %{},
                 size_fixed: false,
               }
             ) == {
               :ok,
               {
                 %Field{
                   width: 1,
                   height: 2,
                   body: %{{0, 0} => "x", {0, 1} => "x"},
                   size_fixed: false,
                 },
                 %{{0, 0} => {nil, "x"}, {0, 1} => {nil, "x"}}
               }
             }
    end

    test "when field size is not fixed and field isn't empty" do
      assert Drawing.apply(
               @valid_rectangle,
               %Field{
                 width: 1,
                 height: 1,
                 body: %{{0, 0} => "."},
                 size_fixed: false,
               }
             ) == {
               :ok,
               {
                 %Field{
                   width: 1,
                   height: 2,
                   body: %{{0, 0} => "x", {0, 1} => "x"},
                   size_fixed: false,
                 },
                 %{{0, 0} => {".", "x"}, {0, 1} => {nil, "x"}}
               }
             }
    end

    test "when field size is not fixed and field is empty and with different start_point" do
      assert Drawing.apply(
               %Rectangle{@valid_rectangle | start_point: %{x: 1, y: 1}},
               %Field{
                 width: nil,
                 height: nil,
                 body: %{},
                 size_fixed: false,
               }
             ) == {
               :ok,
               {
                 %Field{
                   width: 2,
                   height: 3,
                   body: %{{1, 1} => "x", {1, 2} => "x"},
                   size_fixed: false,
                 },
                 %{{1, 1} => {nil, "x"}, {1, 2} => {nil, "x"}}
               }
             }
    end
  end
end
