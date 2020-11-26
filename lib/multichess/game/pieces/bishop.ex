defmodule Multichess.Game.Bishop do
  alias Multichess.Game.Board

  def moves(board, pos) do
    Enum.reduce(directions(), [], fn dir, acc -> acc ++ Board.generate_moves(board, pos, dir) end)
  end

  defp directions do
    [{1, 1}, {1, -1}, {-1, 1}, {-1, -1}]
  end
end
