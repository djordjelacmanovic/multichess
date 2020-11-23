defmodule Multichess.Game.Position.Test do
  alias Multichess.Game.Position
  use ExUnit.Case, async: true

  describe "valid?" do
    test "non integer row is not valid" do
      refute Position.valid?({'1', 4})
    end

    test "non integer column is not valid" do
      refute Position.valid?({1, '4'})
    end

    test "column > 7 is not valid" do
      refute Position.valid?({1, 8})
    end

    test "column < 0 is not valid" do
      refute Position.valid?({1, -1})
    end

    test "non int column is invalid" do
      refute Position.valid?({1, 'a'})
    end

    test "column 0 is valid" do
      assert Position.valid?({1, 0})
    end

    test "column 7 is valid" do
      assert Position.valid?({1, 7})
    end
  end
end
