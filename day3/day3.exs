defmodule Triangle do

  def solve(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
    |> Enum.count(&valid?/1)
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
