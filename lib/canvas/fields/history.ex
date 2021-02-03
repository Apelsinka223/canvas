defmodule Canvas.Fields.History do
  use Ecto.Schema
  alias Canvas.Fields.Field
  alias Canvas.EctoTypes.FieldHistoryChanges
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "fields_history" do
    # %{{x, y} => {old_char, new_char}}}
    field :changes, FieldHistoryChanges

    belongs_to :field, Field

    timestamps()
  end

  @required_data_fields ~w(field_id changes)a
  @optional_data_fields ~w()a

  def changeset(history, attrs) do
    history
    |> cast(attrs, @required_data_fields ++ @optional_data_fields)
    |> validate_required(@required_data_fields)
  end
end
