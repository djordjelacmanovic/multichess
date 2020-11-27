defmodule Multichess.Game.King.Test do
  use ExUnit.Case, async: true
  alias Multichess.Game.King
  alias Multichess.Game.Board

  describe "moves" do
    test "can move in all directions by one" do
      assert %{{4, 4} => %{type: :king, colour: :white}} |> King.moves({4, 4}) |> Enum.sort() ==
               [
                 {3, 5},
                 {4, 5},
                 {5, 5},
                 {3, 4},
                 {5, 4},
                 {3, 3},
                 {4, 3},
                 {5, 3}
               ]
               |> Enum.sort()
    end

    test "cannot move to a blocked square or outside of board" do
      assert Board.initial_state() |> King.moves({4, 0}) == []
    end

    test "can queenside castle when not moved" do
      assert %{{0, 0} => %{type: :rook, colour: :white}, {4, 0} => %{type: :king, colour: :white}}
             |> King.moves({4, 0})
             |> Enum.any?(&(&1 == {2, 0}))
    end

    test "cannot queenside castle when blocked" do
      refute %{
               {0, 0} => %{type: :rook, colour: :white},
               {1, 0} => %{type: :knight, colour: :white},
               {4, 0} => %{type: :king, colour: :white}
             }
             |> King.moves({4, 0})
             |> Enum.any?(&(&1 == {2, 0}))
    end

    test "cannot queenside castle when moved" do
      refute %{
               {0, 0} => %{type: :rook, colour: :white},
               {4, 0} => %{type: :king, colour: :white}
             }
             |> King.moves({4, 0}, [
               %{piece: %{type: :king, colour: :white}}
             ])
             |> Enum.any?(&(&1 == {2, 0}))
    end

    test "cannot queenside castle when queenside rook moved" do
      refute %{
               {0, 0} => %{type: :rook, colour: :white},
               {4, 0} => %{type: :king, colour: :white}
             }
             |> King.moves({4, 0}, [
               %{piece: %{type: :rook, colour: :white}, start_p: {0, 0}}
             ])
             |> Enum.any?(&(&1 == {2, 0}))
    end

    test "can queenside castle when kingside rook moved" do
      assert %{
               {0, 0} => %{type: :rook, colour: :white},
               {4, 0} => %{type: :king, colour: :white}
             }
             |> King.moves({4, 0}, [
               %{piece: %{type: :rook, colour: :white}, start_p: {7, 0}}
             ])
             |> Enum.any?(&(&1 == {2, 0}))
    end

    test "cannot queenside castle when king is in check" do
      refute %{
               {0, 0} => %{type: :rook, colour: :white},
               {4, 0} => %{type: :king, colour: :white},
               {4, 5} => %{type: :rook, colour: :black}
             }
             |> King.moves({4, 0})
             |> Enum.any?(&(&1 == {2, 0}))
    end

    test "cannot queenside castle when one of transition squares is in check" do
      refute %{
               {0, 0} => %{type: :rook, colour: :white},
               {4, 0} => %{type: :king, colour: :white},
               {3, 5} => %{type: :rook, colour: :black}
             }
             |> King.moves({4, 0})
             |> Enum.any?(&(&1 == {2, 0}))
    end

    test "cannot queenside castle when final square is in check" do
      refute %{
               {0, 0} => %{type: :rook, colour: :white},
               {4, 0} => %{type: :king, colour: :white},
               {2, 5} => %{type: :rook, colour: :black}
             }
             |> King.moves({4, 0})
             |> Enum.any?(&(&1 == {2, 0}))
    end

    test "can kingside castle when not moved" do
      assert %{{7, 0} => %{type: :rook, colour: :white}, {4, 0} => %{type: :king, colour: :white}}
             |> King.moves({4, 0})
             |> Enum.any?(&(&1 == {6, 0}))
    end

    test "cannot kingside castle when blocked" do
      refute %{
               {7, 0} => %{type: :rook, colour: :white},
               {5, 0} => %{type: :knight, colour: :white},
               {4, 0} => %{type: :king, colour: :white}
             }
             |> King.moves({4, 0})
             |> Enum.any?(&(&1 == {6, 0}))
    end

    test "cannot kingside castle when moved" do
      refute %{
               {7, 0} => %{type: :rook, colour: :white},
               {4, 0} => %{type: :king, colour: :white}
             }
             |> King.moves({4, 0}, [
               %{piece: %{type: :king, colour: :white}}
             ])
             |> Enum.any?(&(&1 == {6, 0}))
    end

    test "cannot kingside castle when kingside rook moved" do
      refute %{
               {7, 0} => %{type: :rook, colour: :white},
               {4, 0} => %{type: :king, colour: :white}
             }
             |> King.moves({4, 0}, [
               %{piece: %{type: :rook, colour: :white}, start_p: {7, 0}}
             ])
             |> Enum.any?(&(&1 == {6, 0}))
    end

    test "cannot kingside castle when king is in check" do
      refute %{
               {7, 0} => %{type: :rook, colour: :white},
               {4, 0} => %{type: :king, colour: :white},
               {4, 5} => %{type: :rook, colour: :black}
             }
             |> King.moves({4, 0})
             |> Enum.any?(&(&1 == {6, 0}))
    end

    test "cannot kingside castle when one of transition squares is in check" do
      refute %{
               {7, 0} => %{type: :rook, colour: :white},
               {4, 0} => %{type: :king, colour: :white},
               {5, 5} => %{type: :rook, colour: :black}
             }
             |> King.moves({4, 0})
             |> Enum.any?(&(&1 == {6, 0}))
    end

    test "cannot kingside castle when final square is in check" do
      refute %{
               {7, 0} => %{type: :rook, colour: :white},
               {4, 0} => %{type: :king, colour: :white},
               {6, 5} => %{type: :rook, colour: :black}
             }
             |> King.moves({4, 0})
             |> Enum.any?(&(&1 == {6, 0}))
    end

    test "can kingside castle when queenside rook moved" do
      assert %{
               {7, 0} => %{type: :rook, colour: :white},
               {4, 0} => %{type: :king, colour: :white}
             }
             |> King.moves({4, 0}, [
               %{piece: %{type: :rook, colour: :white}, start_p: {0, 0}}
             ])
             |> Enum.any?(&(&1 == {6, 0}))
    end

    test "can capture pieces but not it's own colour" do
      assert %{
               {4, 4} => %{type: :king, colour: :white},
               {3, 4} => %{type: :pawn, colour: :white},
               {4, 5} => %{type: :pawn, colour: :black}
             }
             |> King.moves({4, 4})
             |> Enum.sort() ==
               [
                 {3, 5},
                 {4, 5},
                 {5, 5},
                 {5, 4},
                 {3, 3},
                 {4, 3},
                 {5, 3}
               ]
               |> Enum.sort()
    end
  end
end
