alias Canvas.Drawing.{Coordinate, Rectangle, FloodFill}

defprotocol Canvas.Drawing do
  @fallback_to_any true

  @type drawing :: Rectangle.t() | FloodFill.t()

  @spec parse(drawing :: any(), type :: atom()) :: {:ok, drawing()} | {:error, term()}
  def parse(drawing, type)

  @spec apply(drawing :: any(), field :: Field.t()) ::
          {:ok, {field :: Field.t(), changes :: map()}} | {:error, term()}
  def apply(drawing, field)
end

defimpl Canvas.Drawing, for: Map do
  def parse(
        %{start_point: %{x: x, y: y} = start_point, fill_char: fill_char} = flood_fill,
        :flood_fill
      )
      when is_integer(x) and x >= 0 and is_integer(y) and y >= 0 and is_binary(fill_char) do
    {:ok, struct(FloodFill, %{flood_fill | start_point: struct(Coordinate, start_point)})}
  end

  def parse(
        %{start_point: %{x: x, y: y} = start_point, width: width, height: height} = rectangle,
        :rectangle
      )
      when is_integer(x) and x >= 0 and
             is_integer(y) and y >= 0 and
             is_integer(width) and width > 0 and
             is_integer(height) and height > 0 do
    if (is_binary(rectangle[:outline_char]) or is_nil(rectangle[:outline_char])) and
         (is_binary(rectangle[:fill_char]) or is_nil(rectangle[:fill_char])) and
         (rectangle[:outline_char] || rectangle[:fill_char]) do
      {:ok, struct(Rectangle, %{rectangle | start_point: struct(Coordinate, start_point)})}
    else
      {:error, :invalid_drawing}
    end
  end

  def parse(_, _), do: {:error, :invalid_drawing}
end

defimpl Canvas.Drawing, for: Any do
  def parse(_, _), do: {:error, :invalid_drawing}
  def apply(_, _), do: {:error, :invalid_drawing}
end
