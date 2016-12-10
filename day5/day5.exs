defmodule PasswordCracker do

  def solve(input) do
    solve(input, 0, [])
  end

  defp solve(_input, _index, chars) when length(chars) == 8 do
    chars |> Enum.reverse |> Enum.join
  end

  defp solve(input, index, chars) do
    hash = md5("#{input}#{index}")
    new_chars = case get_char(hash) do
      { :ok, char } -> [char | chars]
      _ -> chars
    end
    solve(input, index + 1, new_chars)
  end

  defp get_char("00000" <> <<char::binary-size(1)>> <> _rest), do: { :ok, char }
  defp get_char(_), do: { :error, "no match" }

  defp md5(data) do
    Base.encode16(:erlang.md5(data), case: :lower)
  end

end

PasswordCracker.solve("abbhdwsy")
|> IO.puts
