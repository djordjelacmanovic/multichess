defmodule Multichess.Game.King do
  alias Multichess.Game.Board

  def moves(board, {c, r}, previous_moves \\ []) do
    moves =
      for(i <- -1..1, j <- -1..1, do: {i, j})
      |> Enum.reject(&(&1 == {0, 0}))
      |> Enum.reduce([], fn {i, j}, acc -> [{c + i, r + j} | acc] end)

    Board.generate_moves(board, {c, r}, moves) ++ castling(board, {c, r}, previous_moves)
  end

  defp castling(board, {4, r}, previous_moves) when r == 0 or r == 7 do
    colour = Board.piece(board, {4, r}).colour

    if not king_has_moved?(colour, previous_moves) do
      [
        queenside_castling(board, colour, {4, r}, previous_moves),
        kingside_castling(board, colour, {4, r}, previous_moves)
      ]
      |> Enum.filter(&(!!&1))
    else
      []
    end
  end

  defp castling(_board, _pos, _prev), do: []

  defp queenside_castling(board, colour, {4, r}, previous_moves) do
    with %{type: :rook, colour: ^colour} <- Board.piece(board, {0, r}),
         false <- rook_has_moved?(colour, {0, r}, previous_moves),
         false <- blocked_or_checked_on_queenside?(board, colour, r) do
      {2, r}
    else
      _ -> nil
    end
  end

  defp blocked_or_checked_on_queenside?(board, colour, r) do
    [{1, r}, {2, r}, {3, r}] |> Enum.any?(&(!!Board.piece(board, &1))) ||
      [{4, r}, {3, r}, {2, r}]
      |> Enum.any?(fn pos ->
        board |> Board.move({4, r}, pos) |> Map.get(:board) |> Board.is_king_checked?(colour)
      end)
  end

  defp kingside_castling(board, colour, {4, r}, previous_moves) do
    with %{type: :rook, colour: ^colour} <- Board.piece(board, {7, r}),
         false <- rook_has_moved?(colour, {7, r}, previous_moves),
         false <- blocked_or_checked_on_kingside?(board, colour, r) do
      {6, r}
    else
      _ -> nil
    end
  end

  defp blocked_or_checked_on_kingside?(board, colour, r) do
    [{5, r}, {6, r}] |> Enum.any?(&(!!Board.piece(board, &1))) ||
      [{4, r}, {5, r}, {6, r}]
      |> Enum.any?(fn pos ->
        board
        |> Board.move({4, r}, pos)
        |> Map.get(:board)
        |> Board.is_king_checked?(colour)
      end)
  end

  defp king_has_moved?(colour, previous_moves),
    do: Enum.any?(previous_moves, &match?(%{piece: %{type: :king, colour: ^colour}}, &1))

  defp rook_has_moved?(colour, start_p, previous_moves),
    do:
      Enum.any?(
        previous_moves,
        &match?(%{piece: %{type: :rook, colour: ^colour}, start_p: ^start_p}, &1)
      )
end
