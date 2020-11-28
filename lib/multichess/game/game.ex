defmodule Multichess.Game do
  alias Multichess.Game.Board

  def initial(), do: %{turn: :white, board: Board.initial_state(), moves: [], captured_pieces: []}

  def move(game_state, from_p, to_p) do
    %{board: board, turn: turn} = game_state

    case Board.piece(board, from_p) do
      nil -> {:error, "no piece at position"}
      %{colour: ^turn} -> exec_move(game_state, from_p, to_p)
      _ -> {:error, "not your turn"}
    end
  end

  defp exec_move(game_state, from_p, to_p) do
    with {:ok, _} <- game_state |> valid_move?(from_p, to_p) do
      {:ok,
       game_state |> Map.get(:board) |> Board.move(from_p, to_p) |> update_game_state(game_state)}
    else
      {:error, message} -> {:error, message}
    end
  end

  defp update_game_state(
         %{board: board, captured: captured, piece: piece, start_p: start_p, end_p: end_p},
         game_state
       ) do
    %{
      board: board,
      moves:
        (game_state
         |> Map.get(:moves)) ++
          [%{start_p: start_p, end_p: end_p, piece: piece}],
      turn: game_state |> Map.get(:turn) |> flip_turn(),
      captured_pieces: game_state |> Map.get(:captured_pieces) |> append_if_not_nil(captured)
    }
  end

  defp append_if_not_nil(list, nil), do: list
  defp append_if_not_nil(list, el), do: list ++ [el]

  defp flip_turn(:white), do: :black
  defp flip_turn(:black), do: :white

  defp valid_move?(%{board: board, turn: turn, moves: prev_moves}, from_p, to_p) do
    cond do
      board |> Board.moves(from_p, prev_moves) |> Enum.any?(&(&1 == to_p)) |> negate ->
        {:error, "not an available move for selected piece"}

      board
      |> Board.move(from_p, to_p)
      |> Map.get(:board)
      |> Board.is_king_checked?(turn) ->
        {:error, "king would be in check"}

      true ->
        {:ok, nil}
    end
  end

  defp negate(b), do: !b
end
