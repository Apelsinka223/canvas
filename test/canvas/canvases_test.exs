defmodule Canvas.FieldsTest do
  use Canvas.DataCase

  alias Canvas.Fields

  describe "fields" do
    alias Canvas.Fields.Field

    @valid_attrs %{body: []}
    @update_attrs %{body: []}
    @invalid_attrs %{body: nil}

    def field_fixture(attrs \\ %{}) do
      {:ok, field} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Fields.create_field()

      field
    end

    test "list_fields/0 returns all fields" do
      field = field_fixture()
      assert Fields.list_fields() == [field]
    end

    test "get_field!/1 returns the field with given id" do
      field = field_fixture()
      assert Fields.get_field!(field.id) == field
    end

    test "create_field/1 with valid data creates a field" do
      assert {:ok, %Field{} = field} = Fields.create_field(@valid_attrs)
      assert field.body == []
    end

    test "create_field/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Fields.create_field(@invalid_attrs)
    end

    test "update_field/2 with valid data updates the field" do
      field = field_fixture()
      assert {:ok, %Field{} = field} = Fields.update_field(field, @update_attrs)
      assert field.body == []
    end

    test "update_field/2 with invalid data returns error changeset" do
      field = field_fixture()
      assert {:error, %Ecto.Changeset{}} = Fields.update_field(field, @invalid_attrs)
      assert field == Fields.get_field!(field.id)
    end

    test "delete_field/1 deletes the field" do
      field = field_fixture()
      assert {:ok, %Field{}} = Fields.delete_field(field)
      assert_raise Ecto.NoResultsError, fn -> Fields.get_field!(field.id) end
    end

    test "change_field/1 returns a field changeset" do
      field = field_fixture()
      assert %Ecto.Changeset{} = Fields.change_field(field)
    end
  end

  describe "history" do
    alias Canvas.Fields.History

    @valid_attrs %{changes: %{}}
    @update_attrs %{changes: %{}}
    @invalid_attrs %{changes: nil}

    def history_fixture(attrs \\ %{}) do
      {:ok, history} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Fields.create_history()

      history
    end

    test "list_history/0 returns all history" do
      history = history_fixture()
      assert Fields.list_history() == [history]
    end

    test "get_history!/1 returns the history with given id" do
      history = history_fixture()
      assert Fields.get_history!(history.id) == history
    end

    test "create_history/1 with valid data creates a history" do
      assert {:ok, %History{} = history} = Fields.create_history(@valid_attrs)
      assert history.changes == %{}
    end

    test "create_history/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Fields.create_history(@invalid_attrs)
    end

    test "update_history/2 with valid data updates the history" do
      history = history_fixture()
      assert {:ok, %History{} = history} = Fields.update_history(history, @update_attrs)
      assert history.changes == %{}
    end

    test "update_history/2 with invalid data returns error changeset" do
      history = history_fixture()
      assert {:error, %Ecto.Changeset{}} = Fields.update_history(history, @invalid_attrs)
      assert history == Fields.get_history!(history.id)
    end

    test "delete_history/1 deletes the history" do
      history = history_fixture()
      assert {:ok, %History{}} = Fields.delete_history(history)
      assert_raise Ecto.NoResultsError, fn -> Fields.get_history!(history.id) end
    end

    test "change_history/1 returns a history changeset" do
      history = history_fixture()
      assert %Ecto.Changeset{} = Fields.change_history(history)
    end
  end
end
