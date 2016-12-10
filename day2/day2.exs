
defmodule Bathroom do

  def solve(input) do
    input
    |> String.split("\n", trim: true)
    |> Bathroom.find_code()
  end

  def find_code(lines) do
    find_code(5, "", lines)
  end

  defp find_code(_starting_number, code, []) do
    code
  end

  defp find_code(starting_number, code, [line | rest]) do
    latest_number = process_line(starting_number, line)
    find_code(latest_number, "#{code}#{latest_number}", rest)
  end

  defp process_line(starting_number, line) do
    coords = coords_for_number(starting_number)
    instructions = String.split(line, "")
    result = Enum.reduce(instructions, coords, &move/2)
    number_for_coords(result)
  end

  defp move("U", {x, y}), do: { x, max(y - 1, 0) }
  defp move("D", {x, y}), do: { x, min(y + 1, 2) }
  defp move("L", {x, y}), do: { max(x - 1, 0), y }
  defp move("R", {x, y}), do: { min(x + 1, 2), y }
  defp move(_, coords), do: coords

  defp coords_for_number(num) do
    { rem(num - 1, 3), div(num - 1, 3) }
  end

  defp number_for_coords({x, y}) do
    (y * 3) + x + 1
  end

end

File.read!("data")
|> Bathroom.solve
|> IO.puts
