defmodule Canvas.ShapeTest do
  use Canvas.DataCase
  alias Canvas.Shape
  alias Canvas.Fields.Field

  @valid_rectangle_params %{
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

  describe "apply/2" do
    test "with correct params, return {Field.t(), map()}" do
      assert Shape.apply(@valid_field, @valid_rectangle_params) == {
               :ok,
               {
                 %Field{
                   width: 10,
                   height: 20,
                   body: %{{0, 0} => "x", {0, 1} => "x"},
                   size_fixed: true
                 },
                 %{{0, 0} => {nil, "x"}, {0, 1} => {nil, "x"}}
               }
             }
    end

    test "fill field with different outline and fill chars" do
      assert Shape.apply(
               @valid_field,
               %{@valid_rectangle_params | width: 3, height: 3}
             ) ==
               {
                 :ok,
                 {
                   %Field{
                     width: 10,
                     height: 20,
                     size_fixed: true,
                     body: %{
                       {0, 0} => "x",
                       {0, 1} => "x",
                       {0, 2} => "x",
                       {1, 0} => "x",
                       {1, 1} => "-",
                       {1, 2} => "x",
                       {2, 0} => "x",
                       {2, 1} => "x",
                       {2, 2} => "x"
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
                     {2, 2} => {nil, "x"}
                   }
                 }
               }
    end

    test "with different start_point" do
      assert Shape.apply(
               @valid_field,
               %{@valid_rectangle_params | width: 3, height: 3, start_point: %{x: 3, y: 3}}
             ) == {
               :ok,
               {
                 %Field{
                   width: 10,
                   height: 20,
                   size_fixed: true,
                   body: %{
                     {3, 3} => "x",
                     {3, 4} => "x",
                     {3, 5} => "x",
                     {4, 3} => "x",
                     {4, 4} => "-",
                     {4, 5} => "x",
                     {5, 3} => "x",
                     {5, 4} => "x",
                     {5, 5} => "x"
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
                   {5, 5} => {nil, "x"}
                 }
               }
             }
    end

    test "when field is empty and size_fixed=false" do
      assert Shape.apply(@valid_field, @valid_rectangle_params) ==
               {
                 :ok,
                 {
                   %Field{
                     width: 10,
                     height: 20,
                     size_fixed: true,
                     body: %{
                       {0, 0} => "x",
                       {0, 1} => "x"
                     }
                   },
                   %{
                     {0, 0} => {nil, "x"},
                     {0, 1} => {nil, "x"}
                   }
                 }
               }
    end

    test "when field is empty and size_fixed=true" do
      assert Shape.apply(@valid_field, @valid_rectangle_params) ==
               {
                 :ok,
                 {
                   %Field{
                     width: 10,
                     height: 20,
                     body: %{
                       {0, 0} => "x",
                       {0, 1} => "x"
                     },
                     size_fixed: true
                   },
                   %{
                     {0, 0} => {nil, "x"},
                     {0, 1} => {nil, "x"}
                   }
                 }
               }
    end

    test "when field has size_fixed=false and start_point is out of field size" do
      assert Shape.apply(
               %Field{
                 width: 1,
                 height: 1,
                 body: %{},
                 size_fixed: false
               },
               %{@valid_rectangle_params | start_point: %{x: 1, y: 1}}
             ) == {
               :ok,
               {
                 %Field{
                   body: %{
                     {1, 1} => "x",
                     {1, 2} => "x"
                   },
                   height: 3,
                   size_fixed: false,
                   width: 2
                 },
                 %{
                   {1, 1} => {nil, "x"},
                   {1, 2} => {nil, "x"}
                 }
               }
             }
    end

    test "when field has size_fixed=true and start_point is out of field size, do nothing" do
      assert {:ok,
              %{
                width: 1,
                height: 1,
                body: %{}
              }} =
               Shape.apply(
                 %Field{
                   width: 1,
                   height: 1,
                   body: %{},
                   size_fixed: true
                 },
                 %{@valid_rectangle_params | start_point: %{x: 100, y: 100}}
               )
    end

    test "when field has size_fixed=true and rectangle shape is out of field size,
         draw the visible part" do
      assert {
               :ok,
               {%Field{
                  width: 1,
                  height: 1,
                  body: %{
                    {0, 0} => "x"
                  },
                  size_fixed: true
                },
                %{
                  {0, 0} => {nil, "x"}
                }}
             } =
               Shape.apply(
                 %Field{
                   width: 1,
                   height: 1,
                   body: %{},
                   size_fixed: true
                 },
                 @valid_rectangle_params
               )
    end

    # .....
    # .....
    # ..aaa
    # ..aaa
    # ..aaa
    test "when field is prefilled with rectangle" do
      assert Shape.apply(
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
                   {4, 4} => "a"
                 },
                 size_fixed: true
               },
               %{@valid_rectangle_params | width: 3, height: 3}
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
                     {4, 4} => "a"
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
                   {2, 2} => {"a", "x"}
                 }
               }
             }
    end

    test "when field size is not fixed and field is empty" do
      assert Shape.apply(
               %Field{
                 width: nil,
                 height: nil,
                 body: %{},
                 size_fixed: false
               },
               @valid_rectangle_params
             ) == {
               :ok,
               {
                 %Field{
                   width: 1,
                   height: 2,
                   body: %{{0, 0} => "x", {0, 1} => "x"},
                   size_fixed: false
                 },
                 %{{0, 0} => {nil, "x"}, {0, 1} => {nil, "x"}}
               }
             }
    end

    test "when field size is not fixed and field isn't empty" do
      assert Shape.apply(
               %Field{
                 width: 1,
                 height: 1,
                 body: %{{0, 0} => "."},
                 size_fixed: false
               },
               @valid_rectangle_params
             ) == {
               :ok,
               {
                 %Field{
                   width: 1,
                   height: 2,
                   body: %{{0, 0} => "x", {0, 1} => "x"},
                   size_fixed: false
                 },
                 %{{0, 0} => {".", "x"}, {0, 1} => {nil, "x"}}
               }
             }
    end

    test "when field size is not fixed and field is empty and with different start_point" do
      assert Shape.apply(
               %Field{
                 width: nil,
                 height: nil,
                 body: %{},
                 size_fixed: false
               },
               %{@valid_rectangle_params | start_point: %{x: 1, y: 1}}
             ) == {
               :ok,
               {
                 %Field{
                   width: 2,
                   height: 3,
                   body: %{{1, 1} => "x", {1, 2} => "x"},
                   size_fixed: false
                 },
                 %{{1, 1} => {nil, "x"}, {1, 2} => {nil, "x"}}
               }
             }
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
        Shape.apply(
          field,
          %{
            start_point: %{x: 3, y: 2},
            width: 5,
            height: 3,
            outline_char: "@",
            fill_char: "X"
          }
        )

      {:ok, {field, _}} =
        Shape.apply(
          field,
          %{
            start_point: %{x: 10, y: 3},
            width: 14,
            height: 6,
            outline_char: "X",
            fill_char: "O"
          }
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
        Shape.apply(
          field,
          %{
            start_point: %{x: 14, y: 0},
            width: 7,
            height: 6,
            outline_char: nil,
            fill_char: "."
          }
        )

      {:ok, {field, _}} =
        Shape.apply(
          field,
          %{
            start_point: %{x: 0, y: 3},
            width: 8,
            height: 4,
            outline_char: "O",
            fill_char: nil
          }
        )

      {:ok, {field, _}} =
        Shape.apply(
          field,
          %{
            start_point: %{x: 5, y: 5},
            width: 5,
            height: 3,
            outline_char: "X",
            fill_char: "X"
          }
        )

      assert field.width == 21
      assert field.height == 8
      assert print(field) == File.read!(Path.join(File.cwd!(), "test/canvas/fixtures/2.txt"))
    end

    defp print(field) do
      for y <- 0..(field.height - 1),
          x <- 0..(field.width - 1),
          reduce: "" do
        acc ->
          acc <> if(x == 0 and y != 0, do: "\n", else: "") <> (field.body[{x, y}] || " ")
      end
    end
  end
end
