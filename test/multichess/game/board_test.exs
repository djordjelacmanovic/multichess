defmodule Multichess.Game.Board.Test do
  use ExUnit.Case, async: true

  alias Multichess.Game.Board

  describe "piece" do
    test "returns piece at given position" do
      piece = %{type: :knight, colour: :white}
      assert piece == %{{1, 2} => piece} |> Board.piece({1, 2})
    end
  end

  describe "is_attacked?" do
    test "returns true if piece is attacked" do
      board = %{
        {1, 0} => %{type: :pawn, colour: :white},
        {1, 7} => %{type: :rook, colour: :black}
      }

      assert Board.is_attacked?({1, 0}, board)
    end

    test "returns false if piece is not attacked" do
      board = %{
        {1, 0} => %{type: :pawn, colour: :white},
        {1, 7} => %{type: :rook, colour: :white}
      }

      refute Board.is_attacked?({1, 0}, board)
    end
  end

  describe "is_king_checked?" do
    test "returns true if king is under attack" do
      assert %{
               {7, 0} => %{type: :rook, colour: :white},
               {4, 0} => %{type: :king, colour: :white},
               {4, 5} => %{type: :rook, colour: :black}
             }
             |> Board.is_king_checked?(:white)
    end

    test "returns true if king is not under attack" do
      refute %{
               {7, 0} => %{type: :rook, colour: :white},
               {4, 0} => %{type: :king, colour: :white},
               {4, 5} => %{type: :bishop, colour: :black}
             }
             |> Board.is_king_checked?(:white)
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

    test "promotes the white pawn if applicable" do
      %{board: board} =
        %{
          {0, 6} => %{type: :pawn, colour: :white}
        }
        |> Board.move({0, 6}, {0, 7})

      assert board == %{{0, 7} => %{type: :queen, colour: :white}}
    end

    test "promotes the black pawn if applicable" do
      %{board: board} =
        %{
          {0, 1} => %{type: :pawn, colour: :black}
        }
        |> Board.move({0, 1}, {0, 0})

      assert board == %{{0, 0} => %{type: :queen, colour: :black}}
    end

    test "performs white queenside castle" do
      %{board: board} =
        %{
          {0, 0} => %{type: :rook, colour: :white},
          {4, 0} => %{type: :king, colour: :white},
          {7, 0} => %{type: :rook, colour: :white}
        }
        |> Board.move({4, 0}, {2, 0})

      assert board == %{
               {3, 0} => %{type: :rook, colour: :white},
               {2, 0} => %{type: :king, colour: :white},
               {7, 0} => %{type: :rook, colour: :white}
             }
    end

    test "performs white kingside castle" do
      %{board: board} =
        %{
          {0, 0} => %{type: :rook, colour: :white},
          {4, 0} => %{type: :king, colour: :white},
          {7, 0} => %{type: :rook, colour: :white}
        }
        |> Board.move({4, 0}, {6, 0})

      assert board == %{
               {0, 0} => %{type: :rook, colour: :white},
               {6, 0} => %{type: :king, colour: :white},
               {5, 0} => %{type: :rook, colour: :white}
             }
    end

    test "performs black queenside castle" do
      %{board: board} =
        %{
          {0, 7} => %{type: :rook, colour: :black},
          {4, 7} => %{type: :king, colour: :black},
          {7, 7} => %{type: :rook, colour: :black}
        }
        |> Board.move({4, 7}, {2, 7})

      assert board == %{
               {3, 7} => %{type: :rook, colour: :black},
               {2, 7} => %{type: :king, colour: :black},
               {7, 7} => %{type: :rook, colour: :black}
             }
    end

    test "performs black kingside castle" do
      %{board: board} =
        %{
          {0, 7} => %{type: :rook, colour: :black},
          {4, 7} => %{type: :king, colour: :black},
          {7, 7} => %{type: :rook, colour: :black}
        }
        |> Board.move({4, 7}, {6, 7})

      assert board == %{
               {0, 7} => %{type: :rook, colour: :black},
               {6, 7} => %{type: :king, colour: :black},
               {5, 7} => %{type: :rook, colour: :black}
             }
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
