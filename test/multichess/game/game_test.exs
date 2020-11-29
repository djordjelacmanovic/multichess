defmodule Multichess.Game.Test do
  use ExUnit.Case, async: true
  alias Multichess.Game

  describe "checked?" do
    test "returns true if player is in check" do
      board = %{
        {1, 0} => %{type: :rook, colour: :white},
        {2, 0} => %{type: :king, colour: :black}
      }

      assert Game.checked?(%{turn: :black, board: board, moves: []})
    end

    test "returns false if player is not in check" do
      board = %{
        {1, 0} => %{type: :rook, colour: :white},
        {2, 1} => %{type: :king, colour: :black}
      }

      refute Game.checked?(%{turn: :black, board: board, moves: []})
    end
  end

  describe "checkmate?" do
    test "returns true if player is checked and has no available moves" do
      board = %{
        {5, 7} => %{type: :rook, colour: :white},
        {7, 6} => %{type: :rook, colour: :white},
        {0, 7} => %{type: :king, colour: :black}
      }

      assert Game.checkmate?(%{board: board, turn: :black, moves: []})
    end

    test "returns true if player is checked but has available moves" do
      board = %{
        {5, 7} => %{type: :rook, colour: :white},
        {7, 6} => %{type: :rook, colour: :white},
        {4, 4} => %{type: :rook, colour: :black},
        {0, 7} => %{type: :king, colour: :black}
      }

      refute Game.checkmate?(%{board: board, turn: :black, moves: []})
    end

    test "returns false if player is not checked" do
      board = %{
        {5, 7} => %{type: :rook, colour: :white},
        {7, 6} => %{type: :rook, colour: :white},
        {4, 4} => %{type: :rook, colour: :black},
        {0, 0} => %{type: :king, colour: :black}
      }

      refute Game.checkmate?(%{board: board, turn: :black, moves: []})
    end
  end

  describe "stalemate?" do
    test "returns true if player has no available moves but is not in check" do
      board = %{
        {1, 0} => %{type: :rook, colour: :white},
        {7, 6} => %{type: :rook, colour: :white},
        {0, 7} => %{type: :king, colour: :black}
      }

      assert Game.stalemate?(%{turn: :black, board: board, moves: []})
    end

    test "returns false if player is checkmated" do
      board = %{
        {5, 7} => %{type: :rook, colour: :white},
        {7, 6} => %{type: :rook, colour: :white},
        {0, 7} => %{type: :king, colour: :black}
      }

      refute Game.stalemate?(%{turn: :black, board: board, moves: []})
    end
  end

  describe "move" do
    test "returns {:error, 'no piece at position'} if no piece at start position" do
      assert Game.move(%{board: %{}, turn: :white, outcome: nil}, {0, 0}, {0, 1}) ==
               {:error, "no piece at position"}
    end

    test "returns {:error, 'not your turn'} if not players turn" do
      assert Game.move(
               %{board: %{{0, 0} => %{type: :pawn, colour: :white}}, turn: :black, outcome: nil},
               {0, 0},
               {0, 1}
             ) == {:error, "not your turn"}
    end

    test "returns {:error, 'game has finished'} if game has any outcome" do
      assert Game.move(
               %{
                 board: %{{0, 0} => %{type: :pawn, colour: :white}},
                 turn: :black,
                 outcome: :stalemate
               },
               {0, 0},
               {0, 1}
             ) == {:error, "game has finished"}
    end

    test "moves the piece and updates the game state" do
      assert Game.move(
               %{
                 board: %{
                   {0, 1} => %{type: :pawn, colour: :white},
                   {1, 2} => %{type: :pawn, colour: :black},
                   {1, 6} => %{type: :pawn, colour: :black},
                   {6, 4} => %{type: :king, colour: :white},
                   {1, 4} => %{type: :king, colour: :black}
                 },
                 turn: :white,
                 moves: [],
                 captured_pieces: [],
                 outcome: nil
               },
               {0, 1},
               {1, 2}
             ) ==
               {:ok,
                %{
                  outcome: nil,
                  checked: false,
                  captured_pieces: [%{type: :pawn, colour: :black}],
                  moves: [
                    %{piece: %{type: :pawn, colour: :white}, start_p: {0, 1}, end_p: {1, 2}}
                  ],
                  turn: :black,
                  board: %{
                    {1, 2} => %{type: :pawn, colour: :white},
                    {1, 6} => %{type: :pawn, colour: :black},
                    {1, 4} => %{type: :king, colour: :black},
                    {6, 4} => %{type: :king, colour: :white}
                  }
                }}
    end

    test "moves the piece and sets checked status" do
      {:ok, %{board: board, checked: true, outcome: nil}} =
        Game.move(
          %{
            board: %{
              {0, 1} => %{type: :rook, colour: :white},
              {6, 6} => %{type: :king, colour: :white},
              {3, 4} => %{type: :king, colour: :black}
            },
            turn: :white,
            moves: [],
            captured_pieces: [],
            outcome: nil
          },
          {0, 1},
          {3, 1}
        )

      assert board == %{
               {3, 1} => %{type: :rook, colour: :white},
               {3, 4} => %{type: :king, colour: :black},
               {6, 6} => %{type: :king, colour: :white}
             }
    end

    test "moves the piece and sets checkmate outcome" do
      {:ok, %{board: board, checked: true, outcome: :checkmate}} =
        Game.move(
          %{
            board: %{
              {4, 1} => %{type: :rook, colour: :white},
              {6, 5} => %{type: :king, colour: :white},
              {6, 7} => %{type: :king, colour: :black}
            },
            turn: :white,
            moves: [],
            captured_pieces: [],
            outcome: nil
          },
          {4, 1},
          {4, 7}
        )

      assert board == %{
               {4, 7} => %{type: :rook, colour: :white},
               {6, 7} => %{type: :king, colour: :black},
               {6, 5} => %{type: :king, colour: :white}
             }
    end

    test "moves piece and sets stalemate outcome" do
      {:ok, %{checked: false, outcome: :stalemate}} =
        Game.move(
          %{
            board: %{
              {4, 0} => %{type: :rook, colour: :white},
              {7, 6} => %{type: :rook, colour: :white},
              {0, 7} => %{type: :king, colour: :black},
              {0, 0} => %{type: :king, colour: :white}
            },
            turn: :white,
            moves: [],
            captured_pieces: [],
            outcome: nil
          },
          {4, 0},
          {1, 0}
        )
    end

    test "returns error if the move would leave king in check" do
      assert Game.move(
               %{
                 board: %{
                   {5, 0} => %{type: :king, colour: :white},
                   {0, 7} => %{type: :king, colour: :black},
                   {2, 0} => %{type: :rook, colour: :black},
                   {4, 0} => %{type: :knight, colour: :white}
                 },
                 turn: :white,
                 outcome: nil,
                 checked: true,
                 moves: [],
                 captured_pieces: []
               },
               {4, 0},
               {3, 2}
             ) == {:error, "king would be in check"}
    end

    test "returns error if the move is not valid for given piece" do
      assert Game.move(
               %{
                 board: %{
                   {5, 0} => %{type: :rook, colour: :white},
                   {4, 0} => %{type: :knight, colour: :white}
                 },
                 turn: :white,
                 outcome: nil,
                 checked: true,
                 moves: [],
                 captured_pieces: []
               },
               {5, 0},
               {4, 0}
             ) == {:error, "not an available move for selected piece"}
    end
  end

  describe "initial" do
    test "returns correct initial game state" do
      assert Game.initial() == %{
               board: Multichess.Game.Board.initial_state(),
               turn: :white,
               moves: [],
               captured_pieces: [],
               checked: false,
               outcome: nil
             }
    end
  end
end
