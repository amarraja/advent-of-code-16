defmodule SslScanner do

  def solve(input) do
    input
    |> String.strip
    |> String.split("\n")
    |> Enum.map(&parse_line/1)
    |> Enum.filter(&is_ssl?/1)
    |> Enum.count
  end

  def parse_line(input) do
    all_strings = List.flatten(Regex.scan(~r/([a-z]+)/, input, capture: :all_but_first))
    hypernet_strings = List.flatten(Regex.scan(~r/\[([a-z]+)\]/, input, capture: :all_but_first))
    address_parts = Enum.reject(all_strings, fn s -> s in hypernet_strings end)
    { address_parts, hypernet_strings }
  end

  def is_ssl?({ address_parts, hypernet_strings }) do
    babs = address_parts
    |> Enum.map(&get_aba/1)
    |> Enum.map(&to_bab/1)

    hypernet_strings
    |> Enum.any?(fn h ->
      Enum.any?(babs, &(String.contains?(h, &1)))
    end)
  end

  def to_bab(list) do
    list
    |> Enum.map(fn [a, b, a] -> "#{b}#{a}#{b}" end)
    |> List.flatten
  end

  defp get_aba(str), do: do_get_aba(String.codepoints(str), [])
  defp do_get_aba([a, b, a | _] = list, acc) when a != b, do: do_get_aba(tl(list), [[a, b, a] | acc])
  defp do_get_aba([_ | tl], acc), do: do_get_aba(tl, acc)
  defp do_get_aba([], acc), do: acc

end

File.read!("data")
|> SslScanner.solve
|> IO.inspect
