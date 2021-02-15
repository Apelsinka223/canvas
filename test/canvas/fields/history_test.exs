defmodule Canvas.Fields.HistoryTest do
  use Canvas.DataCase

  alias Canvas.Fields
  alias Canvas.Fields.History
  alias Canvas.Repo
  alias Ecto.UUID

  describe "create_history/2" do
    setup do
      field = create(:field)

      {:ok, field: field}
    end

    test "creates history", %{field: %{id: field_id}} do
      assert {:ok, %{id: history_id}} =
               Fields.create_history(%{
                 field_id: field_id,
                 changes: %{{0, 0} => {nil, "x"}}
               })

      assert %{
               field_id: ^field_id,
               changes: %{{0, 0} => {nil, "x"}}
             } = Repo.get(History, history_id)
    end

    test "without required parameters, return error", %{field: %{id: field_id}} do
      assert {:error, changeset} =
               Fields.create_history(%{
                 changes: %{{0, 0} => {nil, "x"}}
               })

      assert errors_on(changeset) == %{field_id: ["can't be blank"]}

      assert {:error, changeset} =
               Fields.create_history(%{
                 field_id: field_id
               })

      assert errors_on(changeset) == %{changes: ["can't be blank"]}

      assert Repo.aggregate(History, :count, :id) == 0
    end

    test "when field_id doesn't exist, return error" do
      assert {:error, changeset} =
               Fields.create_history(%{
                 field_id: UUID.generate(),
                 changes: %{{0, 0} => {nil, "x"}}
               })

      assert errors_on(changeset) == %{field_id: ["does not exist"]}

      assert Repo.aggregate(History, :count, :id) == 0
    end

    test "with invalid changes, return error", %{field: field} do
      assert {:error, changeset} =
               Fields.create_history(%{
                 field_id: field.id,
                 changes: %{{0, 0} => {"asd", "a"}}
               })

      assert errors_on(changeset) == %{changes: ["is invalid"]}

      assert {:ok, _} =
               Fields.create_history(%{
                 field_id: field.id,
                 changes: %{{0, 0} => {nil, "a"}}
               })

      assert {:error, changeset} =
               Fields.create_history(%{
                 field_id: field.id,
                 changes: %{{-1, 0} => {"a", "z"}}
               })

      assert errors_on(changeset) == %{changes: ["is invalid"]}

      assert {:error, changeset} =
               Fields.create_history(%{
                 field_id: field.id,
                 changes: %{{0, -1} => {"a", "x"}}
               })

      assert errors_on(changeset) == %{changes: ["is invalid"]}
    end
  end
end
