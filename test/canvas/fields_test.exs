defmodule Canvas.Fields.FieldTest do
  use Canvas.DataCase

  alias Canvas.Fields
  alias Canvas.Fields.Field
  alias Canvas.Repo

  describe "create_field/2" do
    test "creates field" do
      assert {:ok, %{id: field_id}} =
               Fields.create_field(%{
                 width: 10,
                 height: 20,
                 body: %{{0, 0} => "x"}
               })

      assert %{
               width: 10,
               height: 20,
               body: %{{0, 0} => "x"}
             } = Repo.get(Field, field_id)
    end

    test "without parameters, create field with default values" do
      assert {:ok, %{id: field_id}} = Fields.create_field(%{})

      assert %{
               width: nil,
               height: nil,
               body: %{}
             } = Repo.get(Field, field_id)
    end

    test "when height and width weren't passed, fill size_fixed=false" do
      assert {:ok, %{id: field_id}} =
               Fields.create_field(%{
                 body: %{}
               })

      assert %{size_fixed: false} = Repo.get(Field, field_id)
    end

    test "when height and width were passed, fill size_fixed=true" do
      assert {:ok, %{id: field_id}} =
               Fields.create_field(%{
                 width: 10,
                 height: 20,
                 body: %{}
               })

      assert %{size_fixed: true} = Repo.get(Field, field_id)
    end
  end
end
