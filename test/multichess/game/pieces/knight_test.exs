defmodule Multichess.Game.Knight.Test do
  use ExUnit.Case, async: true
  alias Multichess.Game.Knight
  alias Multichess.Game.Board

  describe "moves" do
    test "two fields available from initial positions" do
      assert [{0, 2}, {2, 2}] == Board.initial_state() |> Knight.moves({1, 0}) |> Enum.sort()
    end

    test "generates list of possible positions" do
      assert %{{3, 3} => %{type: :knight, colour: :white}} |> Knight.moves({3, 3}) |> Enum.sort() ==
               Enum.sort([{1, 2}, {1, 4}, {2, 1}, {2, 5}, {4, 1}, {4, 5}, {5, 2}, {5, 4}])
    end

    test "fields blocked by same colour are not returned" do
      assert %{
               {3, 3} => %{type: :knight, colour: :white},
               {1, 2} => %{type: :pawn, colour: :white},
               {2, 5} => %{type: :pawn, colour: :white}
             }
             |> Knight.moves({3, 3})
             |> Enum.sort() ==
               Enum.sort([{1, 4}, {2, 1}, {4, 1}, {4, 5}, {5, 2}, {5, 4}])
    end

    test "fields taken by opposite colour are returned" do
      assert %{
               {3, 3} => %{type: :knight, colour: :white},
               {1, 2} => %{type: :pawn, colour: :black},
               {2, 5} => %{type: :pawn, colour: :black}
             }
             |> Knight.moves({3, 3})
             |> Enum.sort() ==
               Enum.sort([{1, 2}, {1, 4}, {2, 1}, {2, 5}, {4, 1}, {4, 5}, {5, 2}, {5, 4}])
    end
  end
end
