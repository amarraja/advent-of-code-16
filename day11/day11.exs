defmodule Factory do

  def initial(floors) do
    inventory = floors |> List.flatten |> Enum.count

    %{
      elevator: 0,
      inventory: inventory,
      floors: floors,
      depth: 0
    }
  end

  def floors_valid?(floors), do: Enum.all?(floors, &floor_valid?/1)
  def floor_valid?([]), do: true
  def floor_valid?(items) do
    chips = items |> Enum.filter(fn { type, _ } -> :chip === type end)
    gens = items |> Enum.filter(fn { type, _ } -> :gen === type end)
    Enum.count(gens) == 0 || Enum.all?(chips, fn { _, element } ->
      Enum.any?(items, fn g -> { :gen, element } === g end)
    end)
  end

  def reached_goal?(state) do
    state.floors |> Enum.at(3) |> Enum.count == state.inventory
  end

  def next_moves(state, seen, depth \\ 0) do
    directions = case state.elevator do
      0 -> [1]
      3 -> [-1]
      _ -> [1, -1]
    end

    movables = pairs(Enum.at(state.floors, state.elevator))
    new_floors = for movable <- movables, dir <- directions do
      {
        state.elevator + dir,
        state.floors
        |> List.update_at(state.elevator, fn floor -> Enum.sort(floor -- movable) end)
        |> List.update_at(state.elevator + dir, fn floor -> Enum.sort(floor ++ movable) end),
        depth + 1
      }
    end

    Enum.filter(new_floors, fn { elevator, floors, _ } ->
      floors_valid?(floors) && !MapSet.member?(seen, {elevator, floors})
    end)
  end

  def pairs(items) do
    pairs = for a <- items, b <- items, a != b, do: Enum.sort([ a, b ])
    Enum.uniq(Enum.map(items, fn s -> [s] end) ++ pairs)
  end

  def run_state(state) do
    seen = MapSet.new
    run_state(state, next_moves(state, seen), seen)
  end

  def run_state(_state, [] = _moves, _seen) do
    IO.puts "Run out of moves..."
  end

  def run_state(state, [ {elevator, floors, depth} | moves], seen) do
    if MapSet.member?(seen, {elevator, floors}) do
        run_state(state, moves, seen)
    else
      new_state = %{ state | elevator: elevator, floors: floors, depth: depth }
      if reached_goal?(new_state) do
        "Found at depth: #{depth}"
      else
        new_moves = moves ++ next_moves(new_state, seen, depth)
        run_state(new_state, new_moves, MapSet.put(seen, {elevator, floors}))
      end
    end
  end

end


IO.inspect Factory.run_state(Factory.initial([
  [{ :chip, :strontium }, { :gen, :strontium }, { :chip, :plutonium }, { :gen, :plutonium } ],
  [{ :gen, :thulium}, { :chip, :ruthenium }, { :gen, :ruthenium }, { :chip, :curium }, { :gen, :curium } ],
  [{ :chip, :thulium}],
  [ ]
]))

# IO.inspect Factory.run_state(Factory.initial([
#   [{ :chip, :strontium }, { :gen, :strontium }, { :chip, :plutonium }, { :gen, :plutonium }, { :chip, :elerium }, { :gen, :elerium }, { :chip, :dilithium }, { :gen, :dilithium } ],
#   [{ :gen, :thulium}, { :chip, :ruthenium }, { :gen, :ruthenium }, { :chip, :curium }, { :gen, :curium } ],
#   [{ :chip, :thulium}],
#   [ ]
# ]))
