
defmodule Roomfinder do

  defmodule Room do
    defstruct [:letters, :sector_id, :provided_checksum, :actual_checksum]
  end

  def solve(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_room/1)
    |> Enum.filter(&valid?/1)
    |> Enum.map(& &1.sector_id)
    |> Enum.sum()
  end

  def valid?(%Room{} = room) do
    room.provided_checksum === room.actual_checksum
  end

  def parse_room(line) do
    letters = Regex.scan(~r/([a-z]+)-/, line)
              |> Enum.map(&Kernel.tl/1)
              |> Enum.join()

    matches = Regex.named_captures(~r/(?<sector_id>[0-9]+)\[(?<checksum>[a-z]+)\]/, line)

    %Room{
      letters: letters,
      sector_id: String.to_integer(matches["sector_id"]),
      provided_checksum: matches["checksum"],
      actual_checksum: calculate_checksum(letters)
    }
  end

  def calculate_checksum(letters) do
    letters
      |> String.codepoints()
      |> Enum.group_by(& &1)
      |> Enum.map(fn {char, chars} -> { char, length(chars) } end)
      |> Enum.sort_by(fn { letter, _ } -> letter end, &<=/2)
      |> Enum.sort_by(fn { _, count } -> count end, &>=/2)
      |> Enum.take(5)
      |> Enum.map(fn { letter, _ } -> letter end)
      |> Enum.join()
  end

end

File.read!("data")
|> Roomfinder.solve()
|> IO.inspect()
