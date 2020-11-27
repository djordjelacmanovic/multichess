defmodule Multichess.Game.Rook do
  alias Multichess.Game.Board

  def moves(board, pos),
    do: Enum.reduce(directions(), [], &(&2 ++ Board.generate_moves(board, pos, &1)))

  defp directions do
    [{0, 1}, {0, -1}, {1, 0}, {-1, 0}]
  end
end
