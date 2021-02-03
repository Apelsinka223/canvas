defmodule Canvas.Schemas.CustomTypes do
  use Absinthe.Schema.Notation

  scalar :uuid do
    parse fn
      %Absinthe.Blueprint.Input.String{value: value} ->
        case Ecto.UUID.cast(value) do
          {:ok, _} -> {:ok, value}
          _ -> :error
        end

      %Absinthe.Blueprint.Input.Null{} ->
        {:ok, nil}

      _ ->
        :error
    end

    serialize & &1
  end

  scalar :positive_integer, name: "PositiveInt" do
    description """
    Integer > 0
    """

    parse fn
      %Absinthe.Blueprint.Input.Integer{value: value} ->
        if value > 0 do
          {:ok, value}
        else
          :error
        end

      %Absinthe.Blueprint.Input.Null{} ->
        {:ok, nil}

      _ ->
        :error
    end

    serialize & &1
  end

  scalar :char, name: "Char" do
    parse fn
      %Absinthe.Blueprint.Input.String{value: <<value::bytes-size(1)>>} when is_binary(value) ->
        if value > 0 do
          {:ok, value}
        end

      %Absinthe.Blueprint.Input.Null{} ->
        {:ok, nil}

      _ ->
        :error
    end

    serialize & &1
  end

  scalar :json do
    parse fn
      %Absinthe.Blueprint.Input.String{value: value} ->
        case Jason.decode(value) do
          {:ok, result} -> {:ok, result}
          _ -> :error
        end

      %Absinthe.Blueprint.Input.Null{} ->
        {:ok, nil}

      _ ->
        :error
    end

    serialize &Jason.encode!/1
  end
end
