
defmodule GridProcessor do

  def solve(input) do
    input
    |> String.split(",")
    |> Enum.map(&String.strip/1)
    |> Enum.reduce({"N", 0, 0}, &GridProcessor.walk/2)
    |> GridProcessor.calculate_distance
  end

  def walk(instruction, { heading, x, y }) do
    { direction, distance } = parse_instruction(instruction)

    new_heading = turn(direction, heading)
    { new_x, new_y } = move(new_heading, distance, { x, y })

    { new_heading, new_x, new_y }
  end

  def calculate_distance({_, x, y}) do
    abs(x) + abs(y)
  end

  defp turn("L", current), do: process_turn(current, &Kernel.-/2)
  defp turn("R", current), do: process_turn(current, &Kernel.+/2)

  defp move("N", distance, { x, y }), do: { x, y + distance }
  defp move("E", distance, { x, y }), do: { x + distance, y }
  defp move("S", distance, { x, y }), do: { x, y - distance }
  defp move("W", distance, { x, y }), do: { x - distance, y }

  @directions ["N", "E", "S", "W"]
  defp process_turn(current, index_modifier) do
    current_index = Enum.find_index(@directions, & &1 == current)
    new_index = index_modifier.(current_index, 1)
    Enum.at(@directions, rem(new_index, 4))
  end

  defp parse_instruction(<<direction::binary-size(1)>> <> distance) do
    { direction, String.to_integer(distance) }
  end

end


File.read!("data")
|> GridProcessor.solve
|> IO.puts
