defmodule Triangle do

  def solve(input) do
    input
    |> String.split("\n", trim: true)
    |> parse
    |> Enum.count(&valid?/1)
  end

  def parse(input) do
    input
    |> Enum.map(&parse_line/1)
    |> Enum.reduce(%{}, &row_to_cols/2)
    |> Map.values
    |> List.flatten
    |> Enum.chunk(3)
  end

  defp row_to_cols(row, map) do
    row
    |> Enum.with_index
    |> Enum.reduce(map, fn { val, index }, acc ->
      Map.update(acc, index, [val], fn acc -> acc ++ [val] end)
    end)
  end

  def parse_line(line) do
    line
    |> String.split(" ", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  def valid?([a, b, c]) when (a + b > c)
                         and (a + c > b)
                         and (b + c > a) do
    true
  end

  def valid?(_) do
    false
  end


end

File.read!("data")
|> Triangle.solve
|> IO.puts
