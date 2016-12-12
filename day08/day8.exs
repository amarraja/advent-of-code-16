defmodule Screen do
  def solve(input) do
    screen = create_screen(50, 6)
    input
    |> parse_commands
    |> execute_commands(screen)
    |> print_screen
    |> count_active
  end

  defp parse_commands(input) do
    input
    |> String.strip
    |> String.split("\n")
    |> Enum.map(&parse_command/1)
  end

  defp parse_command("rect" <> _ = s) do
    [_, a, b] = Regex.run(~r/rect (\d+)x(\d+)/, s)
    { :rect, String.to_integer(a), String.to_integer(b) }
  end

  defp parse_command("rotate row" <> _ = s) do
    [_, row, by] = Regex.run(~r/rotate row y=(\d+) by (\d+)/, s)
    { :rotate_row, String.to_integer(row), String.to_integer(by) }
  end

  defp parse_command("rotate column" <> _ = s) do
    [_, col, by] = Regex.run(~r/rotate column x=(\d+) by (\d+)/, s)
    { :rotate_col, String.to_integer(col), String.to_integer(by) }
  end

  defp create_screen(width, height) do
    screen = %{
      width_range: 0..width - 1,
      height_range: 0..height - 1
    }
    screen = for x <- screen.width_range, y <- screen.height_range, into: screen do
      { { x, y }, false }
    end
  end

  defp print_screen(screen) do
    screen.height_range
    |> Enum.each(fn y ->
      screen.width_range
      |> Enum.each(fn x ->
        cell = screen[{x, y}]
        IO.write(if cell, do: "#", else: ".")
      end)
      IO.puts ""
    end)
    screen
  end

  defp execute_commands(commands, screen) do
    Enum.reduce(commands, screen, &execute_command/2)
  end

  defp execute_command({ :rect, across, down }, screen) do
    coords = for x <- 0..across - 1, y <- 0..down - 1, into: [], do: { x, y }
    Enum.reduce(coords, screen, &activate_pixel/2)
  end

  defp execute_command({ :rotate_row, row, by }, screen) do
    get_row(row, screen)
    |> rotate_right(by)
    |> apply_pixels(screen, & { &1, row })
  end

  defp execute_command({ :rotate_col, col, by }, screen) do
    get_col(col, screen)
    |> rotate_right(by)
    |> apply_pixels(screen, & { col, &1 })
  end

  defp apply_pixels(pixels, screen, coords_builder) do
    pixels
    |> Enum.with_index
    |> Enum.reduce(screen, fn {value, idx}, screen ->
      set_pixel(coords_builder.(idx), value, screen)
    end)
  end

  defp activate_pixel({ x, y }, screen) do
    %{ screen | {x, y} => true }
  end

  defp set_pixel({ x, y }, value, screen) do
    Map.put(screen, {x, y}, value)
  end

  defp get_row(row, screen) do
    for x <- screen.width_range, into: [], do: screen[{x, row}]
  end

  defp get_col(col, screen) do
    for y <- screen.height_range, into: [], do: screen[{col, y}]
  end

  defp count_active(screen) do
    all = for y <- screen.height_range, x <- screen.width_range, into: [], do: screen[{x, y}]
    Enum.count(all, fn v -> v end)
  end

  defp rotate_left(list, 0), do: list
  defp rotate_left([h | t], count), do: rotate_left(t ++ [h], count - 1)
  defp rotate_right(list, count), do: list |> Enum.reverse |> rotate_left(count) |> Enum.reverse

end

File.read!("data")
|> Screen.solve
|> IO.inspect
