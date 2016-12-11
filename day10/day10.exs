defmodule Factory do

  defmodule Bot do
    use GenServer

    def start_link([name, _, _] = attrs) do
      GenServer.start_link(__MODULE__, attrs, name: name)
    end

    def init([name, low_target, high_target]) do
      { :ok, { name, low_target, high_target, [] } }
    end

    def accept_chip(pid, value) do
      GenServer.call(pid, { :accept_chip, value })
    end


    def handle_call({ :accept_chip, value }, _, { name, low_target, high_target, [] }) do
      {:reply, :ok, { name, low_target, high_target, [value] }}
    end

    def handle_call({ :accept_chip, value }, _, { name, low_target, high_target, [current] }) do
      [low, high] = Enum.sort([current, value])

      Bot.accept_chip(low_target, low)
      Bot.accept_chip(high_target, high)

      send(:master, { name, low, high })

      {:reply, :ok, { name, low_target, high_target, [] }}
    end

  end

  def solve(input) do
    Process.register(self(), :master)
    instructions = input |> String.strip |> String.split("\n", trim: true)

    make_bots(instructions)

    for output <- 0..20 do
      target = String.to_atom("output #{output}")
      Bot.start_link([target, nil, nil])
    end

    send_values(instructions)

    wait_for_output(17, 61)
  end

  def wait_for_output(low, high) do
    receive do
      { bot, ^low, ^high } -> "#{bot}, low: #{low}, high: #{high}"
      _ -> wait_for_output(low, high)
    end
  end

  def make_bots(instructions) do
    instructions
    |> Enum.filter(fn line -> String.starts_with?(line, "bot") end)
    |> Enum.map(fn line ->
      names = Regex.scan(~r/(\w+ \d+)/, line, capture: :all_but_first)
        |> List.flatten
        |> Enum.map(&String.to_atom/1)
      Bot.start_link(names)
    end)
  end

  def send_values(instructions) do
    instructions
    |> Enum.filter(fn line -> String.starts_with?(line, "value") end)
    |> Enum.map(fn line ->
      [value, target] = Regex.run(~r/(\d+) goes to (\w+ \d+)/,  line, capture: :all_but_first)
      value = String.to_integer(value)
      Bot.accept_chip(String.to_atom(target), value)
    end)
  end


end

File.read!("data")
|> Factory.solve
|> IO.inspect
