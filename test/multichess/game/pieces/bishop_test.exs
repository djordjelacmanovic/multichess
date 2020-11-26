defmodule Multichess.Game.Bishop.Test do
  use ExUnit.Case, async: true
  alias Multichess.Game.Bishop
  alias Multichess.Game.Board

  describe "moves" do
    test "cannot move in initial position" do
      assert [] == Board.initial_state() |> Bishop.moves({2, 0})
    end

    test "moves and captures diagonally" do
      %{board: test_board} = Board.initial_state() |> Board.move({2, 0}, {2, 3})

      assert test_board |> Bishop.moves({2, 3}) |> Enum.sort() ==
               Enum.sort([
                 {1, 2},
                 {1, 4},
                 {0, 5},
                 {3, 2},
                 {3, 4},
                 {4, 5},
                 {5, 6}
               ])
    end
  end
end
