defmodule Multichess.Game.Board do
  alias Multichess.Game.Knight
  alias Multichess.Game.Rook
  alias Multichess.Game.Position
  alias Multichess.Game.Queen
  alias Multichess.Game.Bishop
  alias Multichess.Game.Pawn

  def moves(board, pos, previous_moves \\ []) do
    %{type: type} = piece(board, pos)

    case type do
      :knight ->
        Knight.moves(board, pos)

      :rook ->
        Rook.moves(board, pos)

      :bishop ->
        Bishop.moves(board, pos)

      :queen ->
        Queen.moves(board, pos)

      :pawn ->
        Pawn.moves(board, pos, previous_moves)
    end
  end

  def move(board, start_p, end_p) do
    {piece, board} = Map.pop(board, start_p)
    {captured, board} = Map.pop(board, end_p)

    %{
      start_p: start_p,
      end_p: end_p,
      board: Map.put(board, end_p, piece),
      piece: piece,
      captured: captured
    }
  end

  def piece(board, pos) do
    board[pos]
  end

  def generate_moves(board, {c, r}, move_rule) do
    colour = piece(board, {c, r}).colour
    generate_moves(board, colour, {c, r}, move_rule)
  end

  defp generate_moves(board, colour, {c, r}, {dc, dr}) do
    pos = {c + dc, r + dr}

    cond do
      !Position.valid?(pos) || taken(board, colour, pos) ->
        []

      can_capture?(board, colour, pos) ->
        [pos]

      true ->
        [pos | generate_moves(board, colour, pos, {dc, dr})]
    end
  end

  defp generate_moves(_board, _colour, _pos, []), do: []

  defp generate_moves(board, colour, pos, [{c, r} | moves]) do
    cond do
      !Position.valid?({c, r}) || taken(board, colour, {c, r}) ->
        generate_moves(board, colour, pos, moves)

      can_capture?(board, colour, {c, r}) ->
        [{c, r} | generate_moves(board, colour, pos, moves)]

      true ->
        [{c, r} | generate_moves(board, colour, pos, moves)]
    end
  end

  defp can_capture?(board, :white, {c, r}) do
    piece = board[{c, r}]
    piece && piece.colour == :black
  end

  defp can_capture?(board, :black, {c, r}) do
    piece = board[{c, r}]
    piece && piece.colour == :white
  end

  defp taken(board, colour, {c, r}) do
    piece = piece(board, {c, r})
    piece && piece.colour == colour
  end

  def initial_state do
    s = %{
      {0, 0} => make_piece(:rook, :white),
      {1, 0} => make_piece(:knight, :white),
      {2, 0} => make_piece(:bishop, :white),
      {3, 0} => make_piece(:queen, :white),
      {4, 0} => make_piece(:king, :white),
      {5, 0} => make_piece(:bishop, :white),
      {6, 0} => make_piece(:knight, :white),
      {7, 0} => make_piece(:rook, :white),
      {0, 7} => make_piece(:rook, :white),
      {1, 7} => make_piece(:knight, :white),
      {2, 7} => make_piece(:bishop, :white),
      {3, 7} => make_piece(:queen, :white),
      {4, 7} => make_piece(:king, :white),
      {5, 7} => make_piece(:bishop, :white),
      {6, 7} => make_piece(:knight, :white),
      {7, 7} => make_piece(:rook, :white)
    }

    s = Enum.reduce(0..7, s, fn i, acc -> Map.put(acc, {i, 1}, make_piece(:pawn, :white)) end)
    Enum.reduce(0..7, s, fn i, acc -> Map.put(acc, {i, 6}, make_piece(:pawn, :black)) end)
  end

  defp make_piece(type, colour) do
    %{type: type, colour: colour}
  end
end
