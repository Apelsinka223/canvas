defmodule Canvas.Repo.Migrations.CreateFields do
  use Ecto.Migration

  def change do
    create table(:fields, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :body, :map
      add :width, :integer
      add :height, :integer
      add :size_fixed, :boolean

      timestamps()
    end
  end
end
