defmodule Multichess.Game.Pawn do
  alias Multichess.Game.Board

  def moves(board, {c, r}, previous_moves \\ []) do
    colour = (board |> Board.piece({c, r})).colour

    regular_moves(board, colour, {c, r}) ++
      attacks(board, colour, {c, r}, List.last(previous_moves))
  end

  defp regular_moves(board, :white, {c, r}) do
    cond do
      blocked?(board, {c, r + 1}) -> []
      r == 1 -> [{c, r + 1} | regular_moves(board, :white, {c, r + 1})]
      true -> [{c, r + 1}]
    end
  end

  defp regular_moves(board, :black, {c, r}) do
    cond do
      blocked?(board, {c, r - 1}) -> []
      r == 6 -> [{c, r - 1} | regular_moves(board, :black, {c, r - 1})]
      true -> [{c, r - 1}]
    end
  end

  defp blocked?(board, pos), do: !!Board.piece(board, pos)

  defp has_piece_of_colour?(board, pos, colour),
    do: Board.piece(board, pos) |> matches_colour?(colour)

  defp matches_colour?(piece, colour), do: piece && piece.colour == colour
  # en passant
  defp attacks(board, :white, {c, 4}, %{
         piece: %{type: :pawn, colour: :black},
         start_p: {sc, sr},
         end_p: {_ec, er}
       })
       when sr == 6 and (sc == c - 1 or sc == c + 1) and er == 4,
       do: [{sc, 5} | attacks(board, :white, {c, 4}, [])]

  defp attacks(board, :black, {c, 3}, %{
         piece: %{type: :pawn, colour: :white},
         start_p: {sc, sr},
         end_p: {_ec, er}
       })
       when sr == 1 and (sc == c - 1 or sc == c + 1) and er == 3,
       do: [{sc, 2} | attacks(board, :black, {c, 3}, [])]

  defp attacks(board, :white, {c, r}, _prev) do
    Enum.filter([{c - 1, r + 1}, {c + 1, r + 1}], fn p ->
      has_piece_of_colour?(board, p, :black)
    end)
  end

  defp attacks(board, :black, {c, r}, _prev) do
    Enum.filter([{c - 1, r - 1}, {c + 1, r - 1}], fn p ->
      has_piece_of_colour?(board, p, :white)
    end)
  end
end
