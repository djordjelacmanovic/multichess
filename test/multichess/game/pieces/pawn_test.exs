defmodule Multichess.Game.Pawn.Test do
  use ExUnit.Case, async: true
  alias Multichess.Game.Pawn
  alias Multichess.Game.Board

  describe "moves" do
    test "unobstructed pawn on original row can move two squares fwd" do
      assert [{0, 2}, {0, 3}] == Board.initial_state() |> Pawn.moves({0, 1})
    end

    test "obstructed at second square can move one square fwd" do
      assert [{0, 2}] ==
               %{
                 {0, 1} => %{type: :pawn, colour: :white},
                 {0, 3} => %{type: :pawn, colour: :white}
               }
               |> Pawn.moves({0, 1})
    end

    test "obstructed pawn cannot move" do
      assert [] ==
               %{
                 {0, 1} => %{type: :pawn, colour: :white},
                 {0, 2} => %{type: :pawn, colour: :white}
               }
               |> Pawn.moves({0, 1})
    end

    test "is obstructed by pawn of opposite colour" do
      assert [] ==
               %{
                 {0, 1} => %{type: :pawn, colour: :white},
                 {0, 2} => %{type: :pawn, colour: :black}
               }
               |> Pawn.moves({0, 1})
    end

    test "is obstructed by another piece of opposite colour" do
      assert [] ==
               %{
                 {0, 1} => %{type: :pawn, colour: :white},
                 {0, 2} => %{type: :knight, colour: :black}
               }
               |> Pawn.moves({0, 1})
    end

    test "can only move one square forward if not on base row" do
      assert [{0, 3}] ==
               %{
                 {0, 2} => %{type: :pawn, colour: :white}
               }
               |> Pawn.moves({0, 2})
    end

    test "black pawns move down by one square" do
      assert [{0, 1}] ==
               %{
                 {0, 2} => %{type: :pawn, colour: :black}
               }
               |> Pawn.moves({0, 2})
    end

    test "black pawns move down by up to two squares from their base row" do
      assert [{0, 4}, {0, 5}] |> Enum.sort() ==
               %{
                 {0, 6} => %{type: :pawn, colour: :black}
               }
               |> Pawn.moves({0, 6})
               |> Enum.sort()
    end

    test "black pawns are obstructed by a black piece on row below" do
      assert [] ==
               %{
                 {0, 6} => %{type: :pawn, colour: :black},
                 {0, 5} => %{type: :knight, colour: :black}
               }
               |> Pawn.moves({0, 6})
    end

    test "black pawns are obstructed by a white piece on row below" do
      assert [] ==
               %{
                 {0, 6} => %{type: :pawn, colour: :black},
                 {0, 5} => %{type: :knight, colour: :white}
               }
               |> Pawn.moves({0, 6})
    end

    test "white pawns attack up and diagonally" do
      assert [{3, 4}, {1, 4}] |> Enum.sort() ==
               %{
                 {2, 3} => %{type: :pawn, colour: :white},
                 # blocked
                 {2, 4} => %{type: :pawn, colour: :black},
                 {3, 4} => %{type: :knight, colour: :black},
                 {1, 4} => %{type: :knight, colour: :black}
               }
               |> Pawn.moves({2, 3})
               |> Enum.sort()
    end

    test "white pawns dont attack white pieces" do
      assert [] ==
               %{
                 {2, 3} => %{type: :pawn, colour: :white},
                 # blocked
                 {2, 4} => %{type: :pawn, colour: :black},
                 {3, 4} => %{type: :knight, colour: :white},
                 {1, 4} => %{type: :knight, colour: :white}
               }
               |> Pawn.moves({2, 3})
    end

    test "black pawns attack down and diagonally" do
      assert [{3, 2}, {1, 2}] |> Enum.sort() ==
               %{
                 {2, 3} => %{type: :pawn, colour: :black},
                 # blocked
                 {2, 2} => %{type: :pawn, colour: :white},
                 {1, 2} => %{type: :knight, colour: :white},
                 {3, 2} => %{type: :knight, colour: :white}
               }
               |> Pawn.moves({2, 3})
               |> Enum.sort()
    end

    test "black pawns dont attack black pieces" do
      assert [] ==
               %{
                 {2, 3} => %{type: :pawn, colour: :black},
                 # blocked
                 {2, 2} => %{type: :pawn, colour: :white},
                 {1, 2} => %{type: :knight, colour: :black},
                 {3, 2} => %{type: :knight, colour: :black}
               }
               |> Pawn.moves({2, 3})
    end

    test "white pawns can do en passan to the left in correct conditions" do
      assert [{3, 5}] ==
               %{
                 {4, 4} => %{type: :pawn, colour: :white},
                 # blocked
                 {4, 5} => %{type: :pawn, colour: :black},
                 {3, 4} => %{type: :pawn, colour: :black}
               }
               |> Pawn.moves({4, 4}, [
                 %{start_p: {3, 6}, end_p: {3, 4}, piece: %{type: :pawn, colour: :black}}
               ])
    end

    test "white pawns can do en passan to the right in correct conditions" do
      assert [{5, 5}] ==
               %{
                 {4, 4} => %{type: :pawn, colour: :white},
                 # blocked
                 {4, 5} => %{type: :pawn, colour: :black},
                 {5, 4} => %{type: :pawn, colour: :black}
               }
               |> Pawn.moves({4, 4}, [
                 %{start_p: {5, 6}, end_p: {5, 4}, piece: %{type: :pawn, colour: :black}}
               ])
    end

    test "white pawns can't do en passan is previous move by black was not right" do
      assert [] ==
               %{
                 {4, 4} => %{type: :pawn, colour: :white},
                 # blocked
                 {4, 5} => %{type: :pawn, colour: :black},
                 {5, 4} => %{type: :pawn, colour: :black}
               }
               |> Pawn.moves({4, 4}, [
                 %{start_p: {5, 5}, end_p: {5, 4}, piece: %{type: :pawn, colour: :black}}
               ])
    end

    test "white pawns can do leftward en passan and regular capture and move forward" do
      assert [{3, 5}, {4, 5}, {5, 5}] |> Enum.sort() ==
               %{
                 {4, 4} => %{type: :pawn, colour: :white},
                 {3, 4} => %{type: :pawn, colour: :black},
                 {5, 5} => %{type: :knight, colour: :black}
               }
               |> Pawn.moves({4, 4}, [
                 %{start_p: {3, 6}, end_p: {3, 4}, piece: %{type: :pawn, colour: :black}}
               ])
               |> Enum.sort()
    end

    test "black pawns can do leftward en passan and regular attack and move forward" do
      assert [{3, 2}, {2, 2}, {4, 2}] |> Enum.sort() ==
               %{
                 {3, 3} => %{type: :pawn, colour: :black},
                 {2, 3} => %{type: :pawn, colour: :white},
                 {4, 2} => %{type: :knight, colour: :white}
               }
               |> Pawn.moves({3, 3}, [
                 %{start_p: {2, 1}, end_p: {2, 3}, piece: %{type: :pawn, colour: :white}}
               ])
               |> Enum.sort()
    end

    test "black pawns can do rightward en passan" do
      assert [{4, 2}] |> Enum.sort() ==
               %{
                 {3, 3} => %{type: :pawn, colour: :black},
                 {3, 2} => %{type: :pawn, colour: :white},
                 {4, 3} => %{type: :pawn, colour: :white}
               }
               |> Pawn.moves({3, 3}, [
                 %{start_p: {4, 1}, end_p: {4, 3}, piece: %{type: :pawn, colour: :white}}
               ])
               |> Enum.sort()
    end

    test "black pawns cannot do en passan if conditions not right" do
      assert [] ==
               %{
                 {3, 3} => %{type: :pawn, colour: :black},
                 {3, 2} => %{type: :pawn, colour: :white},
                 {4, 3} => %{type: :pawn, colour: :white}
               }
               |> Pawn.moves({3, 3}, [
                 %{start_p: {4, 2}, end_p: {4, 3}, piece: %{type: :pawn, colour: :white}}
               ])
    end
  end
end
