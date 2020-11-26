defmodule Multichess.Game.Rook.Test do
  use ExUnit.Case, async: true
  alias Multichess.Game.Rook
  alias Multichess.Game.Board

  describe "moves" do
    test "cannot move from initial position" do
      assert [] == Board.initial_state() |> Rook.moves({0, 0})
    end

    test "can move and capture horizontally and vertically" do
      %{board: test_board} = Board.initial_state() |> Board.move({0, 0}, {4, 3})

      assert test_board |> Rook.moves({4, 3}) |> Enum.sort() ==
               Enum.sort([
                 {4, 2},
                 {0, 3},
                 {1, 3},
                 {2, 3},
                 {3, 3},
                 {5, 3},
                 {6, 3},
                 {7, 3},
                 {4, 4},
                 {4, 5},
                 {4, 6}
               ])
    end
  end
end
