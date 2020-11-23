defmodule Multichess.Game.Position do
  def valid?({row, col}) when col > 7 or col < 0 do
    false 
  end

  def valid?({row, col}) when row > 7 or row < 0 do 
    false 
  end

  def valid?({row, col}) do
    true 
  end
end