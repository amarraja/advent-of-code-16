defmodule TlsScanner do

  def solve(input) do
    input
    |> String.strip
    |> String.split("\n")
    |> Enum.map(&parse_line/1)
    |> Enum.filter(&is_tls?/1)
    |> Enum.count
  end

  def parse_line(input) do
    all_strings = List.flatten(Regex.scan(~r/([a-z]+)/, input, capture: :all_but_first))
    hypernet_strings = List.flatten(Regex.scan(~r/\[([a-z]+)\]/, input, capture: :all_but_first))
    address_parts = Enum.reject(all_strings, fn s -> s in hypernet_strings end)
    { address_parts, hypernet_strings }
  end

  defp is_tls?({ address_parts, hypernet_strings }) do
    abba_addresses = Enum.filter(address_parts, &has_abba?/1)
    abba_hypernet = Enum.filter(hypernet_strings, &has_abba?/1)
    Enum.count(abba_addresses) > 0 && Enum.count(abba_hypernet) == 0
  end

  def has_abba?(str), do: do_has_abba?(String.codepoints(str))
  defp do_has_abba?([a, b, b, a | _]) when a != b, do: true
  defp do_has_abba?([_ | tl]), do: do_has_abba?(tl)
  defp do_has_abba?([]), do: false

end

File.read!("data")
|> TlsScanner.solve
|> IO.inspect
