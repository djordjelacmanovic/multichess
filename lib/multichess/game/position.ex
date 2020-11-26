defmodule Multichess.Game.Position do
  def parse(str) do
    with [rs, cs] <- String.split(str, ","),
         {r, _} <- Integer.parse(rs),
         {c, _} <- Integer.parse(cs),
         true <- valid?({r, c}) do
      {:ok, {r, c}}
    else
      _ ->
        {:error, "invalid position string"}
    end
  end

  def to_string({r, c}), do: Integer.to_string(r) <> "," <> Integer.to_string(c)

  def valid?({row, _}) when not is_integer(row), do: false
  def valid?({_, col}) when not is_integer(col), do: false

  def valid?({_, col}) when col > 7 or col < 0, do: false
  def valid?({row, _}) when row > 7 or row < 0, do: false

  def valid?({_, _}), do: true
end
