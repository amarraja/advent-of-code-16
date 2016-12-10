defmodule Deflater do

  def solve(input) do
    input
    |> String.strip
    |> process("")
    |> String.length
  end

  def process(%{ "text" => text, "rest" => rest }, acc) when byte_size(text) > 0 do
    process(rest, acc <> text)
  end

  def process(%{ "command" => command, "rest" => rest }, acc) when byte_size(command) > 0 do
    [chars, times] = parse_command(command)
    segment = rest |> String.slice(0, chars) |> String.duplicate(times)
    tail = rest |> String.slice(chars..-1)
    process(tail, acc <> segment)
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

File.read!("data")
|> Deflater.solve
|> IO.inspect
