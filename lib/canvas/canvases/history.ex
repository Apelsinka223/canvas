defmodule Canvas.Canvases.History do
  use Ecto.Schema
  alias Canvas.Canvases.Field
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "history" do
    field :changes, :map

    belongs_to :field, Field

    timestamps()
  end

  @required_data_fields ~w(changes)a
  @optional_data_fields ~w()a

  def changeset(history, attrs) do
    history
    |> cast(attrs, @required_data_fields ++ @optional_data_fields)
    |> validate_required(@required_data_fields)
  end
end
