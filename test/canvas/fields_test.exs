defmodule Canvas.FieldsTest do
  use Canvas.DataCase

  alias Canvas.{Repo, Fields}
  alias Canvas.Fields.{Field, History}
  alias Canvas.Repo

  @valid_rectangle_params %{
    width: 1,
    height: 2,
    start_point: %{x: 0, y: 0},
    outline_char: "x",
    fill_char: "-"
  }

  @valid_flood_fill_params %{
    start_point: %{x: 0, y: 0},
    fill_char: "-"
  }

  describe "add_rectangle/2" do
    setup do
      field = create(:field, body: %{}, size_fixed: false, width: 1, height: 1)

      {:ok, field: field}
    end

    test "update field", %{field: field} do
      assert {:ok, %{id: field_id}} = Fields.add_rectangle(field, @valid_rectangle_params)

      assert %{
               width: 1,
               height: 2,
               body: %{{0, 0} => "x", {0, 1} => "x"},
               size_fixed: false
             } = Repo.get(Field, field_id)
    end

    test "save history", %{field: field} do
      assert {:ok, %{id: field_id}} = Fields.add_rectangle(field, @valid_rectangle_params)

      assert %{
               field_id: ^field_id,
               changes: %{{0, 0} => {nil, "x"}, {0, 1} => {nil, "x"}}
             } = Repo.one(History)
    end

    test "when drawing params are invalid, do not create history", %{field: field} do
      assert {:error, _} = Fields.add_rectangle(field, nil)
      assert {:error, _} = Fields.add_rectangle(field, %{@valid_rectangle_params | width: 0})

      field_fixed = create(:field, body: %{}, size_fixed: true, width: 1, height: 1)

      assert {:error, _} =
               Fields.add_rectangle(field_fixed, %{@valid_rectangle_params | width: 100})

      assert Repo.aggregate(History, :count, :id) == 0
    end
  end

  describe "add_flood_fill/2" do
    setup do
      field =
        create(
          :field,
          body: %{
            {0, 0} => "a",
            {0, 1} => "a"
          },
          size_fixed: false,
          width: 1,
          height: 2
        )

      {:ok, field: field}
    end

    test "update field", %{field: field} do
      assert {:ok, %{id: field_id}} = Fields.add_flood_fill(field, @valid_flood_fill_params)

      assert %{
               width: 1,
               height: 2,
               body: %{{0, 0} => "-", {0, 1} => "-"},
               size_fixed: false
             } = Repo.get(Field, field_id)
    end

    test "save history", %{field: field} do
      assert {:ok, %{id: field_id}} = Fields.add_flood_fill(field, @valid_flood_fill_params)

      assert %{
               field_id: ^field_id,
               changes: %{{0, 0} => {"a", "-"}, {0, 1} => {"a", "-"}}
             } = Repo.one(History)
    end

    test "when drawing params are invalid, do not create history", %{field: field} do
      assert {:error, _} = Fields.add_flood_fill(field, nil)

      assert {:error, _} =
               Fields.add_flood_fill(
                 field,
                 %{@valid_flood_fill_params | start_point: %{x: -1, y: -1}}
               )

      assert {:error, _} =
               Fields.add_flood_fill(
                 field,
                 %{@valid_flood_fill_params | start_point: %{x: 100, y: 100}}
               )
      assert Repo.aggregate(History, :count, :id) == 0
    end
  end

  describe "print/1" do
    test "return serialized field" do
      field = create(:field, width: 1, height: 2, body: %{{0, 0} => "x", {0, 1} => "-"})

      assert """
             x
             -\
             """ = Fields.print(field)
    end

   test "when argument is invalid, raise error" do
     assert_raise FunctionClauseError, fn -> Fields.print(nil) end
    end
  end
end
