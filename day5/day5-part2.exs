defmodule PasswordCracker do

  def solve(input) do
    solve(input, 0, 0, %{})
  end

  defp solve(_input, _index, 8, chars) do
    chars |> Map.values |> Enum.join
  end

  defp solve(input, index, _charlen, chars) do
    hash = md5("#{input}#{index}")
    new_chars = case get_char(hash) do
      { :ok, { index, value } } ->
        Map.put_new(chars, index, value)
      _ ->
        chars
    end
    solved_so_far = new_chars |> Map.keys |> Enum.count
    solve(input, index + 1, solved_so_far, new_chars)
  end

  defp get_char("00000" <> <<idx::utf8, data::binary-size(1)>> <> _rest) when idx >= ?0 and idx <= ?7do
    { :ok, { String.to_integer(<<idx::utf8>>), data } }
  end
  defp get_char(_), do: { :error, "no match" }

  defp md5(data) do
    Base.encode16(:erlang.md5(data), case: :lower)
  end

end

PasswordCracker.solve("abbhdwsy")
|> IO.inspect
