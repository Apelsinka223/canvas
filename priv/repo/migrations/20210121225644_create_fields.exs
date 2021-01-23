defmodule Canvas.Repo.Migrations.CreateFields do
  use Ecto.Migration

  def change do
    create table(:fields) do
      add :body, :map

      timestamps()
    end

  end
end
