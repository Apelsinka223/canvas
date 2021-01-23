defmodule Canvas.Repo.Migrations.CreateFieldsHistory do
  use Ecto.Migration

  def change do
    create table(:fields_history, primary_key: false) do
      add :id, :binary_id
      add :changes, :map
      add :field_id, references(:fields, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:fields_history, [:field_id])
  end
end
