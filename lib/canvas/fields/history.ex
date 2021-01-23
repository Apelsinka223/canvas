defmodule Canvas.History.Field do
  use Ecto.Schema
  alias Canvas.Fields.Field
  alias Canvas.Drawings.Drawing
  alias Canvas.EctoTypes.FieldHistoryChanges
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "fields_history" do
    # %{{x, y} => {old_char, new_char}}}
    field :changes, FieldHistoryChanges

    belongs_to :field, Field
    belongs_to :drawing, Drawing

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
