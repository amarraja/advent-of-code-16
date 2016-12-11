
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

  defp move("U", {x, y} = c), do: try_move(c, { x, max(y - 1, 0) })
  defp move("D", {x, y} = c), do: try_move(c, { x, min(y + 1, 4) })
  defp move("L", {x, y} = c), do: try_move(c, { max(x - 1, 0), y })
  defp move("R", {x, y} = c), do: try_move(c, { min(x + 1, 4), y })
  defp move(_, coords), do: coords

  defp try_move(orig, new) do
    case number_for_coords(new) do
      nil -> orig
      _ -> new
    end
  end

  defp pad do
    [
      [nil, nil,  1,  nil, nil],
      [nil,  2,   3,   4,  nil],
      [ 5,   6,   7,   8,   9 ],
      [nil, "A", "B", "C", nil],
      [nil, nil, "D", nil, nil],
    ]
  end

  defp coords_for_number(num) do
    y = Enum.find_index(pad, fn row -> Enum.find_index(row, &(&1 == num)) end)
    row = Enum.at(pad, y)
    x = Enum.find_index(row, fn n -> n == num end)
    { x, y }
  end

  defp number_for_coords({x, y}) do
    Enum.at(Enum.at(pad, y), x)
  end

end

File.read!("data")
|> Bathroom.solve
|> IO.inspect
