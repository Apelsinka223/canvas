defmodule Canvas.Fields.Field do
  use Ecto.Schema
  import Ecto.Changeset
  alias Canvas.EctoTypes.FieldBody

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "fields" do
    # %{{x, y} => char}
    field :body, FieldBody, default: %{}
    field :width, :integer
    field :height, :integer
    field :size_fixed, :boolean

    timestamps()
  end

  @required_data_fields ~w(body)a
  @optional_data_fields ~w(width height)a

  def create_changeset(field, attrs) do
    field
    |> cast(attrs, @required_data_fields ++ @optional_data_fields)
    |> validate_required(@required_data_fields)
    |> put_change(:size_fixed, not is_nil(attrs[:size]))
  end

  def update_changeset(field, attrs) do
    field
    |> cast(attrs, @required_data_fields ++ @optional_data_fields)
    |> validate_required(@required_data_fields)
    |> validate_size_change()
    |> IO.inspect()
  end

  defp validate_size_change(changeset) do
    if get_field(changeset, :size_fixed) and
         (not is_nil(get_change(changeset, :height)) or
            not is_nil(get_change(changeset, :width))) do
      add_error(changeset, :size, "size of field with fixed size cannot be changed")
    else
      changeset
    end
  end
end
