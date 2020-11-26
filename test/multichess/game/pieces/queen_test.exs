defmodule Multichess.Game.Queen.Test do
  use ExUnit.Case, async: true
  alias Multichess.Game.Board
  alias Multichess.Game.Queen
  alias Multichess.Game.Rook
  alias Multichess.Game.Bishop

  describe "moves" do
    # too lazy rn to type up all the fields

    test "cannot move from initial position" do
      assert [] == Board.initial_state() |> Queen.moves({3, 0})
    end

    test "combines bishop and rook" do
      %{board: test_board} = Board.initial_state() |> Board.move({3, 0}, {3, 3})

      assert test_board |> Queen.moves({3, 3}) |> Enum.sort() ==
               (Bishop.moves(test_board, {3, 3}) ++ Rook.moves(test_board, {3, 3}))
               |> Enum.sort()
    end
  end
end
