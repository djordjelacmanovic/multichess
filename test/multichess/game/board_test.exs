defmodule Multichess.Game.Board.Test do
  use ExUnit.Case, async: true

  alias Multichess.Game.Board

  describe "piece" do
    test "returns piece at given position" do
      piece = %{type: :knight, colour: :white}
      assert piece == %{{1, 2} => piece} |> Board.piece({1, 2})
    end
  end

  describe "move" do
    test "moves the piece" do
      piece = %{type: :bishop, colour: :white}

      %{captured: nil, piece: ^piece, board: %{{2, 2} => ^piece}} =
        %{{1, 2} => piece} |> Board.move({1, 2}, {2, 2})
    end

    test "captures the piece" do
      piece = %{type: :bishop, colour: :white}
      capture = %{type: :pawn, colour: :black}

      %{captured: ^capture, piece: ^piece, board: %{{2, 2} => ^piece}} =
        %{{1, 2} => piece, {2, 2} => capture} |> Board.move({1, 2}, {2, 2})
    end

    test "returns start_p and end_p" do
      start_p = {1, 1}
      end_p = {1, 2}
      %{start_p: ^start_p, end_p: ^end_p} = Board.initial_state() |> Board.move({1, 1}, {1, 2})
    end
  end

  describe "initial state" do
    test "creates correct state" do
      assert correct_initial_state() == Board.initial_state()
    end
  end

  defp correct_initial_state do
    %{
      {0, 0} => %{colour: :white, type: :rook},
      {1, 0} => %{colour: :white, type: :knight},
      {2, 0} => %{colour: :white, type: :bishop},
      {3, 0} => %{colour: :white, type: :queen},
      {4, 0} => %{colour: :white, type: :king},
      {5, 0} => %{colour: :white, type: :bishop},
      {6, 0} => %{colour: :white, type: :knight},
      {7, 0} => %{colour: :white, type: :rook},
      {0, 1} => %{colour: :white, type: :pawn},
      {1, 1} => %{colour: :white, type: :pawn},
      {2, 1} => %{colour: :white, type: :pawn},
      {3, 1} => %{colour: :white, type: :pawn},
      {4, 1} => %{colour: :white, type: :pawn},
      {5, 1} => %{colour: :white, type: :pawn},
      {6, 1} => %{colour: :white, type: :pawn},
      {7, 1} => %{colour: :white, type: :pawn},
      {0, 6} => %{colour: :black, type: :pawn},
      {1, 6} => %{colour: :black, type: :pawn},
      {2, 6} => %{colour: :black, type: :pawn},
      {3, 6} => %{colour: :black, type: :pawn},
      {4, 6} => %{colour: :black, type: :pawn},
      {5, 6} => %{colour: :black, type: :pawn},
      {6, 6} => %{colour: :black, type: :pawn},
      {7, 6} => %{colour: :black, type: :pawn},
      {0, 7} => %{colour: :white, type: :rook},
      {1, 7} => %{colour: :white, type: :knight},
      {2, 7} => %{colour: :white, type: :bishop},
      {3, 7} => %{colour: :white, type: :queen},
      {4, 7} => %{colour: :white, type: :king},
      {5, 7} => %{colour: :white, type: :bishop},
      {6, 7} => %{colour: :white, type: :knight},
      {7, 7} => %{colour: :white, type: :rook}
    }
  end
end
