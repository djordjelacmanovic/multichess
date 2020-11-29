defmodule Multichess.Game do
  alias Multichess.Game.Board

  def initial(),
    do: %{
      turn: :white,
      board: Board.initial_state(),
      moves: [],
      captured_pieces: [],
      checked: false,
      outcome: nil
    }

  def move(game_state, from_p, to_p) do
    %{board: board, turn: turn, outcome: outcome} = game_state

    if outcome do
      {:error, "game has finished"}
    else
      case Board.piece(board, from_p) do
        nil -> {:error, "no piece at position"}
        %{colour: ^turn} -> exec_move(game_state, from_p, to_p)
        _ -> {:error, "not your turn"}
      end
    end
  end

  def checked?(%{board: board, turn: turn}), do: board |> Board.is_king_checked?(turn)

  def checkmate?(state), do: checked?(state) and no_moves_available?(state)

  def stalemate?(state), do: no_moves_available?(state) and !checked?(state)

  defp no_moves_available?(state) do
    state.board
    |> Board.find(%{colour: state.turn})
    |> Enum.any?(fn {pos, _} ->
      state.board |> Board.moves(pos) |> Enum.any?(&match?({:ok, _}, valid_move?(state, pos, &1)))
    end)
    |> negate
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
         %{moves: moves, turn: turn, captured_pieces: captured_pieces}
       ) do
    %{
      board: board,
      moves:
        moves ++
          [%{start_p: start_p, end_p: end_p, piece: piece}],
      turn: turn |> flip_turn(),
      captured_pieces: captured_pieces |> append_if_not_nil(captured)
    }
    |> update_outcome()
  end

  defp update_outcome(state) do
    state
    |> Map.put(:checked, checked?(state))
    |> Map.put(:outcome, outcome(state))
  end

  defp outcome(state) do
    cond do
      checkmate?(state) -> :checkmate
      stalemate?(state) -> :stalemate
      true -> nil
    end
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
