defmodule Multichess.Game.Queen do
  alias Multichess.Game.Rook
  alias Multichess.Game.Bishop

  def moves(board, pos) do
    Bishop.moves(board, pos) ++ Rook.moves(board, pos)
  end
end
