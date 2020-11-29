defmodule Multichess.Game.Position do
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

  def to_string({c, r}), do: "#{c},#{r}"

  def valid?({col, _}) when not is_integer(col), do: false
  def valid?({_, row}) when not is_integer(row), do: false

  def valid?({_, row}) when row > 7 or row < 0, do: false
  def valid?({col, _}) when col > 7 or col < 0, do: false

  def valid?({_, _}), do: true
end
