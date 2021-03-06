defmodule Canvas.Factory do
  use ExMachina.Ecto, repo: Canvas.Repo
  use Canvas.Factory.EctoReturningStrategy, repo: Canvas.Repo
  alias Canvas.Fields.Field

  def field_factory do
    %Field{
      body: %{},
      size_fixed: false
    }
  end
end
