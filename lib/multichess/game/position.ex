defmodule Multichess.Game.Position do
  @spec parse(binary) :: {:error, reason :: binary} | {:ok, {column :: integer, row :: integer}}
  @doc ~S"""
    Parses the given `str` into a position tuple.

    Examples:

      iex> Multichess.Game.Position.parse("4,4")
      {:ok, {4, 4}}

      iex> Multichess.Game.Position.parse("4,9")
      {:error, "invalid position string"}

  """
  def parse(str) do
    with [cs, rs] <- String.split(str, ","),
         {c, _} <- Integer.parse(cs),
         {r, _} <- Integer.parse(rs),
         true <- valid?({c, r}) do
      {:ok, {c, r}}
    else
      _ ->
        {:error, "invalid position string"}
    end
  end

  @spec to_string({integer(), integer()}) :: binary()
  @doc ~S"""
    Converts the given {col, row} integer tuple to a string representation.

    Examples:

      iex> Multichess.Game.Position.to_string({3,4})
      "3,4"

  """
  def to_string({c, r}), do: "#{c},#{r}"

  @spec valid?({integer(), integer()}) :: boolean
  @doc ~S"""
    Checks if the given position tuple is valid.

    Examples:

      iex> Multichess.Game.Position.valid?({4, 4})
      true

      iex> Multichess.Game.Position.valid?({4, 9})
      false

      iex> Multichess.Game.Position.valid?({9, 4})
      false

  """
  def valid?({col, _}) when not is_integer(col), do: false
  def valid?({_, row}) when not is_integer(row), do: false

  def valid?({_, row}) when row > 7 or row < 0, do: false
  def valid?({col, _}) when col > 7 or col < 0, do: false

  def valid?({_, _}), do: true
end
