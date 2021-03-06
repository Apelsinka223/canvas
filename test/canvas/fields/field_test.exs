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

    test "with only one of width and height passed, return error" do
      assert {:error, changeset} = Fields.create_field(%{height: 10})
      assert errors_on(changeset) == %{width: ["height and width should be set together"]}

      assert {:error, changeset} = Fields.create_field(%{width: 10})
      assert errors_on(changeset) == %{height: ["height and width should be set together"]}
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

    test "with invalid width, return error" do
      assert {:error, changeset} =
               Fields.create_field(%{
                 width: -10,
                 height: 20,
                 body: %{}
               })

      assert errors_on(changeset) == %{width: ["must be greater than 0"]}

      assert {:error, changeset} =
               Fields.create_field(%{
                 width: 0,
                 height: 20,
                 body: %{}
               })

      assert errors_on(changeset) == %{width: ["must be greater than 0"]}

      assert Repo.aggregate(Field, :count, :id) == 0
    end

    test "with invalid height, return error" do
      assert {:error, changeset} =
               Fields.create_field(%{
                 width: 10,
                 height: -20,
                 body: %{}
               })

      assert errors_on(changeset) == %{height: ["must be greater than 0"]}

      assert {:error, changeset} =
               Fields.create_field(%{
                 width: 10,
                 height: 0,
                 body: %{}
               })

      assert errors_on(changeset) == %{height: ["must be greater than 0"]}

      assert Repo.aggregate(Field, :count, :id) == 0
    end

    test "with invalid body, return error" do
      assert {:error, changeset} =
               Fields.create_field(%{
                 width: 10,
                 height: 20,
                 body: %{{0, 0} => "asd"}
               })

      assert errors_on(changeset) == %{body: ["is invalid"]}

      assert {:error, changeset} =
               Fields.create_field(%{
                 width: 10,
                 height: 20,
                 body: %{{0, 0} => nil}
               })

      assert errors_on(changeset) == %{body: ["is invalid"]}

      assert {:error, changeset} =
               Fields.create_field(%{
                 width: 10,
                 height: 20,
                 body: %{{-1, 0} => "a"}
               })

      assert errors_on(changeset) == %{body: ["is invalid"]}

      assert {:error, changeset} =
               Fields.create_field(%{
                 width: 10,
                 height: 20,
                 body: %{{0, -1} => "a"}
               })

      assert errors_on(changeset) == %{body: ["is invalid"]}

      assert {:error, changeset} =
               Fields.create_field(%{
                 width: 10,
                 height: 20,
                 body: %{1 => "a"}
               })

      assert errors_on(changeset) == %{body: ["is invalid"]}

      assert Repo.aggregate(Field, :count, :id) == 0
    end
  end

  describe "update_field/2" do
    setup do
      field = create(:field, width: 1, height: 1, size_fixed: false, body: %{{0, 0} => "a"})

      {:ok, field: field}
    end

    test "updates field", %{field: field} do
      assert {:ok, %{id: field_id}} =
               Fields.update_field(
                 field,
                 %{
                   width: 2,
                   height: 1,
                   body: %{{0, 0} => "x", {0, 1} => "a"}
                 }
               )

      assert %{
               width: 2,
               height: 1,
               body: %{{0, 0} => "x", {0, 1} => "a"},
               size_fixed: false
             } = Repo.get(Field, field_id)
    end

    test "without required parameters, return error", %{field: field} do
      assert {:error, changeset} =
               Fields.update_field(
                 field,
                 %{body: nil}
               )

      assert errors_on(changeset) == %{body: ["can't be blank"]}
    end

    test "when size_fixed=true and width and height passed, ignore them" do
      field = create(:field, width: 1, height: 1, size_fixed: true, body: %{{0, 0} => "a"})

      assert {:ok, %{id: field_id}} =
               Fields.update_field(
                 field,
                 %{
                   width: 2,
                   height: 1,
                   body: %{{0, 0} => "x", {0, 1} => "a"}
                 }
               )

      assert %{
               width: 1,
               height: 1,
               body: %{{0, 0} => "x", {0, 1} => "a"},
               size_fixed: true
             } = Repo.get(Field, field_id)
    end

    test "with invalid body, return error", %{field: field} do
      assert {:error, changeset} =
               Fields.update_field(
                 field,
                 %{
                   width: 10,
                   height: 20,
                   body: %{{0, 0} => "asd"}
                 }
               )

      assert errors_on(changeset) == %{body: ["is invalid"]}

      assert {:error, changeset} =
               Fields.update_field(
                 field,
                 %{
                   width: 10,
                   height: 20,
                   body: %{{-1, 0} => "a"}
                 }
               )

      assert errors_on(changeset) == %{body: ["is invalid"]}

      assert {:error, changeset} =
               Fields.update_field(
                 field,
                 %{
                   width: 10,
                   height: 20,
                   body: %{{0, -1} => "a"}
                 }
               )

      assert errors_on(changeset) == %{body: ["is invalid"]}

      assert {:error, changeset} =
               Fields.update_field(
                 field,
                 %{
                   width: 10,
                   height: 20,
                   body: %{1 => "a"}
                 }
               )

      assert errors_on(changeset) == %{body: ["is invalid"]}
    end
  end
end
