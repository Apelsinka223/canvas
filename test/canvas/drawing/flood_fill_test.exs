defmodule Canvas.Drawing.FloodFillTest do
  use Canvas.DataCase
  alias Canvas.Fields.Field
  alias Canvas.Drawing
  alias Canvas.Drawing.FloodFill

  @valid_flood_fill_params %{
    start_point: %{x: 0, y: 0},
    fill_char: "-"
  }

  @valid_flood_fill %FloodFill{
    start_point: %{x: 0, y: 0},
    fill_char: "-"
  }

  @valid_field %Field{
    width: 1,
    height: 2,
    body: %{},
    size_fixed: true
  }

  describe "parse/2" do
    test "with correct params, return FloodFill.t()" do
      assert {
               :ok,
               %FloodFill{
                 start_point: %{x: 0, y: 0},
                 fill_char: "-"
               }
             } = Drawing.parse(@valid_flood_fill_params, :flood_fill)
    end

    test "with incorrect params type, return error" do
      assert {:error, :invalid_drawing} =
               Drawing.parse(
                 %{@valid_flood_fill_params | start_point: %{x: "0", y: 0}},
                 :flood_fill
               )

      assert {:error, :invalid_drawing} =
               Drawing.parse(
                 %{@valid_flood_fill_params | start_point: %{x: -10, y: 0}},
                 :flood_fill
               )

      assert {:error, :invalid_drawing} =
               Drawing.parse(
                 %{@valid_flood_fill_params | start_point: %{x: 0, y: "0"}},
                 :flood_fill
               )

      assert {:error, :invalid_drawing} =
               Drawing.parse(
                 %{@valid_flood_fill_params | start_point: %{x: 0, y: -10}},
                 :flood_fill
               )

      assert {:error, :invalid_drawing} =
               Drawing.parse(%{@valid_flood_fill_params | fill_char: 0}, :flood_fill)
    end
  end

  describe "apply/2" do
    test "with correct params, return {Field.t(), map()}" do
      assert Drawing.apply(@valid_flood_fill, @valid_field) == {
               :ok,
               {
                 %Field{
                   width: 1,
                   height: 2,
                   body: %{
                     {0, 0} => "-",
                     {0, 1} => "-"
                   },
                   size_fixed: true
                 },
                 %{
                   {0, 0} => {nil, "-"},
                   {0, 1} => {nil, "-"}
                 }
               }
             }
    end

    test "with different start_point" do
      assert Drawing.apply(
               %FloodFill{
                 @valid_flood_fill
                 | start_point: %{
                     x: 0,
                     y: 1
                   }
               },
               @valid_field
             ) == {
               :ok,
               {
                 %Field{
                   width: 1,
                   height: 2,
                   body: %{
                     {0, 0} => "-",
                     {0, 1} => "-"
                   },
                   size_fixed: true
                 },
                 %{
                   {0, 0} => {nil, "-"},
                   {0, 1} => {nil, "-"}
                 }
               }
             }
    end

    test "with different char at start_point" do
      assert Drawing.apply(@valid_flood_fill, %Field{@valid_field | body: %{{0, 0} => "."}}) == {
               :ok,
               {
                 %Field{
                   width: 1,
                   height: 2,
                   body: %{
                     {0, 0} => "-"
                   },
                   size_fixed: true
                 },
                 %{
                   {0, 0} => {".", "-"}
                 }
               }
             }
    end

    test "when field is empty and size_fixed=false, return error" do
      assert {:error, :out_of_range} =
               Drawing.apply(
                 @valid_flood_fill,
                 %Field{
                   body: %{},
                   size_fixed: false
                 }
               )
    end

    test "when field is empty and size_fixed=true" do
      assert Drawing.apply(
               @valid_flood_fill,
               %Field{
                 width: 1,
                 height: 1,
                 body: %{},
                 size_fixed: true
               }
             ) == {
               :ok,
               {
                 %Field{
                   width: 1,
                   height: 1,
                   body: %{{0, 0} => "-"},
                   size_fixed: true
                 },
                 %{{0, 0} => {nil, "-"}}
               }
             }
    end

    test "when start_point is out of field size, return error" do
      assert {:error, :out_of_range} =
               Drawing.apply(
                 %FloodFill{@valid_flood_fill | start_point: %{x: 1, y: 1}},
                 %Field{
                   width: 1,
                   height: 1,
                   body: %{},
                   size_fixed: false
                 }
               )
    end

    test "when field is prefilled with flood_fill" do
      assert Drawing.apply(
               %FloodFill{@valid_flood_fill | start_point: %{x: 1, y: 1}},
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
                   {4, 4} => "a"
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
                     {0, 0} => "-",
                     {0, 1} => "-",
                     {0, 2} => "-",
                     {0, 3} => "-",
                     {0, 4} => "-",
                     {1, 0} => "-",
                     {1, 1} => "-",
                     {1, 2} => "-",
                     {1, 3} => "-",
                     {1, 4} => "-",
                     {2, 0} => "-",
                     {2, 1} => "-",
                     {2, 2} => "-",
                     {2, 3} => "-",
                     {2, 4} => "-",
                     {3, 0} => "-",
                     {3, 1} => "-",
                     {3, 2} => "-",
                     {3, 3} => "-",
                     {3, 4} => "-",
                     {4, 0} => "-",
                     {4, 1} => "-",
                     {4, 2} => "-",
                     {4, 3} => "-",
                     {4, 4} => "-"
                   },
                   size_fixed: true
                 },
                 %{
                   {0, 0} => {"a", "-"},
                   {0, 1} => {"a", "-"},
                   {0, 2} => {"a", "-"},
                   {0, 3} => {"a", "-"},
                   {0, 4} => {"a", "-"},
                   {1, 0} => {"a", "-"},
                   {1, 1} => {"a", "-"},
                   {1, 2} => {"a", "-"},
                   {1, 3} => {"a", "-"},
                   {1, 4} => {"a", "-"},
                   {2, 0} => {"a", "-"},
                   {2, 1} => {"a", "-"},
                   {2, 2} => {"a", "-"},
                   {2, 3} => {"a", "-"},
                   {2, 4} => {"a", "-"},
                   {3, 0} => {"a", "-"},
                   {3, 1} => {"a", "-"},
                   {3, 2} => {"a", "-"},
                   {3, 3} => {"a", "-"},
                   {3, 4} => {"a", "-"},
                   {4, 0} => {"a", "-"},
                   {4, 1} => {"a", "-"},
                   {4, 2} => {"a", "-"},
                   {4, 3} => {"a", "-"},
                   {4, 4} => {"a", "-"}
                 }
               }
             }
    end

    # .....    -----
    # .....    -----
    # aaaaa -> aaaaa
    # a...a    a...a
    # aaaaa    aaaaa
    test "when field is prefilled with rectangle" do
      assert Drawing.apply(
               %FloodFill{@valid_flood_fill | start_point: %{x: 1, y: 1}},
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
                   {3, 3} => ".",
                   {3, 4} => "a",
                   {4, 0} => ".",
                   {4, 1} => ".",
                   {4, 2} => "a",
                   {4, 3} => "a",
                   {4, 4} => "a"
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
                     {0, 0} => "-",
                     {0, 1} => "-",
                     {0, 2} => "-",
                     {0, 3} => "-",
                     {0, 4} => "-",
                     {1, 0} => "-",
                     {1, 1} => "-",
                     {1, 2} => "-",
                     {1, 3} => "-",
                     {1, 4} => "-",
                     {2, 0} => "-",
                     {2, 1} => "-",
                     {2, 2} => "a",
                     {2, 3} => "a",
                     {2, 4} => "a",
                     {3, 0} => "-",
                     {3, 1} => "-",
                     {3, 2} => "a",
                     {3, 3} => ".",
                     {3, 4} => "a",
                     {4, 0} => "-",
                     {4, 1} => "-",
                     {4, 2} => "a",
                     {4, 3} => "a",
                     {4, 4} => "a"
                   },
                   size_fixed: true
                 },
                 %{
                   {0, 0} => {".", "-"},
                   {0, 1} => {".", "-"},
                   {0, 2} => {".", "-"},
                   {0, 3} => {".", "-"},
                   {0, 4} => {".", "-"},
                   {1, 0} => {".", "-"},
                   {1, 1} => {".", "-"},
                   {1, 2} => {".", "-"},
                   {1, 3} => {".", "-"},
                   {1, 4} => {".", "-"},
                   {2, 0} => {".", "-"},
                   {2, 1} => {".", "-"},
                   {3, 0} => {".", "-"},
                   {3, 1} => {".", "-"},
                   {4, 0} => {".", "-"},
                   {4, 1} => {".", "-"}
                 }
               }
             }
    end

    # .....    .....
    # .....    .....
    # aaaaa -> aaaaa
    # a...a    a---a
    # aaaaa    aaaaa
    test "when field is prefilled with rectangle, inside rectangle" do
      assert Drawing.apply(
               %FloodFill{@valid_flood_fill | start_point: %{x: 3, y: 3}},
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
                   {2, 0} => "a",
                   {2, 1} => "a",
                   {2, 2} => "a",
                   {2, 3} => "a",
                   {2, 4} => "a",
                   {3, 0} => "a",
                   {3, 1} => ".",
                   {3, 2} => ".",
                   {3, 3} => ".",
                   {3, 4} => "a",
                   {4, 0} => "a",
                   {4, 1} => "a",
                   {4, 2} => "a",
                   {4, 3} => "a",
                   {4, 4} => "a"
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
                     {2, 0} => "a",
                     {2, 1} => "a",
                     {2, 2} => "a",
                     {2, 3} => "a",
                     {2, 4} => "a",
                     {3, 0} => "a",
                     {3, 1} => "-",
                     {3, 2} => "-",
                     {3, 3} => "-",
                     {3, 4} => "a",
                     {4, 0} => "a",
                     {4, 1} => "a",
                     {4, 2} => "a",
                     {4, 3} => "a",
                     {4, 4} => "a"
                   },
                   size_fixed: true
                 },
                 %{
                   {3, 1} => {".", "-"},
                   {3, 2} => {".", "-"},
                   {3, 3} => {".", "-"}
                 }
               }
             }
    end

    # .....    .....
    # .....    .....
    # aaaaa -> -----
    # a...a    -...-
    # aaaaa    -----
    test "when field is prefilled with rectangle, at the rectangle border" do
      assert Drawing.apply(
               %FloodFill{@valid_flood_fill | start_point: %{x: 3, y: 0}},
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
                   {2, 0} => "a",
                   {2, 1} => "a",
                   {2, 2} => "a",
                   {2, 3} => "a",
                   {2, 4} => "a",
                   {3, 0} => "a",
                   {3, 1} => ".",
                   {3, 2} => ".",
                   {3, 3} => ".",
                   {3, 4} => "a",
                   {4, 0} => "a",
                   {4, 1} => "a",
                   {4, 2} => "a",
                   {4, 3} => "a",
                   {4, 4} => "a"
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
                     {2, 0} => "-",
                     {2, 1} => "-",
                     {2, 2} => "-",
                     {2, 3} => "-",
                     {2, 4} => "-",
                     {3, 0} => "-",
                     {3, 1} => ".",
                     {3, 2} => ".",
                     {3, 3} => ".",
                     {3, 4} => "-",
                     {4, 0} => "-",
                     {4, 1} => "-",
                     {4, 2} => "-",
                     {4, 3} => "-",
                     {4, 4} => "-"
                   },
                   size_fixed: true
                 },
                 %{
                   {2, 0} => {"a", "-"},
                   {2, 1} => {"a", "-"},
                   {2, 2} => {"a", "-"},
                   {2, 3} => {"a", "-"},
                   {2, 4} => {"a", "-"},
                   {3, 0} => {"a", "-"},
                   {3, 4} => {"a", "-"},
                   {4, 0} => {"a", "-"},
                   {4, 1} => {"a", "-"},
                   {4, 2} => {"a", "-"},
                   {4, 3} => {"a", "-"},
                   {4, 4} => {"a", "-"}
                 }
               }
             }
    end

    # . ..    - --
    # ...  -> ---
    #  ..      --
    # ...     ---
    # ^
    test "when field is prefilled with complex figure, required following backward path" do
      assert Drawing.apply(
               %FloodFill{@valid_flood_fill | start_point: %{x: 3, y: 0}},
               %Field{
                 width: 4,
                 height: 4,
                 body: %{
                   {0, 0} => ".",
                   {0, 2} => ".",
                   {0, 3} => ".",
                   {1, 0} => ".",
                   {1, 1} => ".",
                   {1, 2} => ".",
                   {2, 2} => ".",
                   {2, 3} => ".",
                   {3, 0} => ".",
                   {3, 1} => ".",
                   {3, 2} => "."
                 },
                 size_fixed: true
               }
             ) == {
               :ok,
               {
                 %Field{
                   width: 4,
                   height: 4,
                   body: %{
                     {0, 0} => "-",
                     {0, 2} => "-",
                     {0, 3} => "-",
                     {1, 0} => "-",
                     {1, 1} => "-",
                     {1, 2} => "-",
                     {2, 2} => "-",
                     {2, 3} => "-",
                     {3, 0} => "-",
                     {3, 1} => "-",
                     {3, 2} => "-"
                   },
                   size_fixed: true
                 },
                 %{
                   {0, 0} => {".", "-"},
                   {0, 2} => {".", "-"},
                   {0, 3} => {".", "-"},
                   {1, 0} => {".", "-"},
                   {1, 1} => {".", "-"},
                   {1, 2} => {".", "-"},
                   {2, 2} => {".", "-"},
                   {2, 3} => {".", "-"},
                   {3, 0} => {".", "-"},
                   {3, 1} => {".", "-"},
                   {3, 2} => {".", "-"}
                 }
               }
             }
    end
  end
end
