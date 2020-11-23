defmodule Multichess.Game.Position do
  def valid?({row, _}) when not is_integer(row), do: false
  def valid?({_, col}) when not is_integer(col), do: false

  def valid?({_, col}) when col > 7 or col < 0, do: false
  def valid?({row, _}) when row > 7 or row < 0, do: false

  def valid?({_, _}), do: true
end
