defmodule Canvas.Drawing.Coordinate do
  @type t :: %__MODULE__{
          x: non_neg_integer(),
          y: non_neg_integer()
        }

  defstruct [:x, :y]
end
