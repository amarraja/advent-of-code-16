defmodule Decoder do

  def solve_most_common(input), do: solve(input, &Enum.max_by/2)
  def solve_least_common(input), do: solve(input, &Enum.min_by/2)

  defp solve(input, comparator) do
    input
    |> String.strip
    |> String.split("\n")
    |> Enum.map(&String.codepoints/1)
    |> decode_password(comparator)
  end

  defp decode_password(codepoints, comparator) do
    codepoints
    |> Enum.flat_map(&Enum.with_index/1)
    |> Enum.group_by(fn { _, index } -> index end, fn { char, _ } -> char end)
    |> Enum.map(fn { _, value } -> most_relevant_letter(value, comparator) end)
    |> Enum.join
  end

  defp most_relevant_letter(list, comparator) do
    {char, _} = list
    |> Enum.group_by(& &1)
    |> comparator.(fn { _, chars } -> length(chars) end)

    char
  end

end

IO.puts "Most common"
File.read!("data")
|> Decoder.solve_most_common
|> IO.inspect

IO.puts "Least common"
File.read!("data")
|> Decoder.solve_least_common
|> IO.inspect
