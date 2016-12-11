
defmodule GridProcessor do

  def solve(input) do
    history = MapSet.new |> MapSet.put({0, 0})
    input
    |> String.split(",")
    |> Enum.map(&String.strip/1)
    |> walk({"N", 0, 0 }, history)
    |> GridProcessor.calculate_distance
  end

  def walk([], coords, _history) do
    coords
  end

  def walk([instruction | rest], { heading, x, y }, history) do
    { direction, distance } = parse_instruction(instruction)

    new_heading = turn(direction, heading)
    case move_incremental(new_heading, distance, { x, y }, history) do
      { :twice, { new_x, new_y } } ->
        { new_heading, new_x, new_y }
      { :continue, { new_x, new_y }, history } ->
        walk(rest, { new_heading, new_x, new_y }, history)
    end
  end

  def calculate_distance({_, x, y}) do
    abs(x) + abs(y)
  end

  defp turn("L", current), do: process_turn(current, &Kernel.-/2)
  defp turn("R", current), do: process_turn(current, &Kernel.+/2)

  defp move_incremental(heading, 0, to, history) do
    { :continue, to, history }
  end

  defp move_incremental(heading, distance, to, history) do
    new_coords = move(heading, 1, to)
    if MapSet.member?(history, new_coords) do
      { :twice, new_coords }
    else
      move_incremental(heading, distance - 1, new_coords, MapSet.put(history, new_coords))
    end
  end

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
