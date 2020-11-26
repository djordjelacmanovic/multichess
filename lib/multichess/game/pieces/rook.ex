defmodule Multichess.Game.Rook do
  alias Multichess.Game.Board

  def moves(board, pos) do
    Enum.reduce(directions(), [], fn dir, acc -> acc ++ Board.generate_moves(board, pos, dir) end)
  end

  defp directions do
    [{0, 1}, {0, -1}, {1, 0}, {-1, 0}]
  end
end
