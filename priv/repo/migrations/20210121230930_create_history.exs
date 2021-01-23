defmodule Canvas.Repo.Migrations.CreateHistory do
  use Ecto.Migration

  def change do
    create table(:history) do
      add :changes, :map
      add :field_id, references(:fields, on_delete: :nothing)

      timestamps()
    end

    create index(:history, [:field_id])
  end
end
