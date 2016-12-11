defmodule Deflater do

  def solve(input) do
    input
    |> String.strip
    |> process(0)
  end

  def process(%{ "text" => text, "rest" => rest }, acc) when byte_size(text) > 0 do
    process(rest, acc + String.length(text))
  end

  def process(%{ "command" => command, "rest" => rest }, acc) when byte_size(command) > 0 do
    [chars, times] = parse_command(command)
    { segment, tail } = rest |> String.split_at(chars)
    process(tail, acc + process(segment, 0) * times)
  end

  def process(nil, acc) do
    acc
  end

  def process(str, acc) do
    Regex.named_captures(~r/((?<text>[A-Z]+)|(?<command>\(\d+x\d+\)))(?<rest>.*)/, str)
    |> process(acc)
  end

  def parse_command(command) do
    Regex.run(~r/\((\d+)x(\d+)\)/, command, capture: :all_but_first)
    |> Enum.map(&String.to_integer/1)
  end

end

IO.inspect(Deflater.solve("(25x3)(3x3)ABC(2x3)XY(5x2)PQRSTX(18x9)(3x2)TWO(5x7)SEVEN"))
IO.inspect(Deflater.solve("(27x12)(20x12)(13x14)(7x10)(1x12)A"))

File.read!("data")
|> Deflater.solve
|> IO.inspect
