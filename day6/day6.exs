defmodule Decoder do

  def solve(input) do
    input
    |> String.strip
    |> String.split("\n")
    |> Enum.map(&String.codepoints/1)
    |> decode_password
  end

  defp decode_password(codepoints) do
    codepoints
    |> Enum.flat_map(&Enum.with_index/1)
    |> Enum.group_by(fn { _, index } -> index end, fn { char, _ } -> char end)
    |> Enum.map(fn { _, value } -> most_common_letter(value) end)
    |> Enum.join
  end

  defp most_common_letter(list) do
    {char, _} = list
    |> Enum.group_by(& &1)
    |> Enum.max_by(fn { _, chars } -> length(chars) end)

    char
  end

end

File.read!("data")
|> Decoder.solve
|> IO.inspect
