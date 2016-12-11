
defmodule Roomfinder do

  defmodule Room do
    defstruct [:name, :decoded_name, :sector_id, :provided_checksum, :actual_checksum]
  end

  def solve(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_room/1)
    |> Enum.filter(&valid?/1)
    |> print_rooms
    |> Enum.map(& &1.sector_id)
    |> Enum.sum()
  end

  def print_rooms(rooms) do
    rooms
    |> Enum.each(fn room ->
      IO.puts "Name: #{room.name}"
      IO.puts "Decoded Name: #{room.decoded_name}"
      IO.puts "Sector: #{room.sector_id}\n\n"
    end)
    rooms
  end

  def valid?(%Room{} = room) do
    room.provided_checksum === room.actual_checksum
  end

  def parse_room(line) do
    name = Regex.scan(~r/([a-z]+-)/, line)
              |> Enum.map(&Kernel.tl/1)
              |> Enum.join()

    matches = Regex.named_captures(~r/(?<sector_id>[0-9]+)\[(?<checksum>[a-z]+)\]/, line)
    sector_id = String.to_integer(matches["sector_id"])

    %Room{
      name: name,
      decoded_name: decode_name(name, sector_id),
      sector_id: sector_id,
      provided_checksum: matches["checksum"],
      actual_checksum: calculate_checksum(name)
    }
  end

  def decode_name(str, shift) do
    str
    |> String.codepoints
    |> Enum.map(&(translate_char(&1, shift)))
    |> Enum.join
  end

  def translate_char("-", _), do: " "
  def translate_char("", _), do: ""
  def translate_char(<<chr::utf8>>, shift) do
    index = chr + shift
    rotated = rem(index - ?a, (?z-?a) + 1) + ?a
    <<rotated::utf8>>
  end

  def calculate_checksum(letters) do
    letters
      |> String.replace("-", "")
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
