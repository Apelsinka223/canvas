defmodule Canvas.Fields.Coordinate do
  @moduledoc """
  Coordinate struct.
  """

  @type t :: %__MODULE__{
          x: non_neg_integer(),
          y: non_neg_integer()
        }

  @type coordinate :: %{
          required(:x) => non_neg_integer(),
          required(:y) => non_neg_integer()
        }

  defstruct [:x, :y]
end
