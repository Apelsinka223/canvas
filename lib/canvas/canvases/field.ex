defmodule Canvas.Canvases.Field do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "fields" do
    field :body, :map

    timestamps()
  end

  @required_data_fields ~w(body)a
  @optional_data_fields ~w()a

  def changeset(history, attrs) do
    history
    |> cast(attrs, @required_data_fields ++ @optional_data_fields)
    |> validate_required(@required_data_fields)
  end
end
