defmodule Day14 do

  def parse_chem(chem) do
    [pn, pname] = String.split(chem,  " ")
    pnum = String.to_integer(pn)
    [pname, pnum]
  end

  def read_input(file) do
    File.stream!(file)
    |> Stream.map(&String.trim/1)
    |> Enum.reduce(%{}, fn s, acc ->
      [req, p] = String.split(s, " => ")
      [pname, pnum] = parse_chem(p)
      requirements = req |> String.split(", ") |> Enum.map(&parse_chem/1)
      Map.put(acc, pname, {pnum, requirements})
    end)
  end

  def produce(prod, n, reactions, surplus) do
    {outnum, reqs} = reactions[prod]
    left_in_surplus = Map.get(surplus, prod, 0)
    actualn = n - min(left_in_surplus, n)
    left_in_surplus = left_in_surplus - min(left_in_surplus, n)
    overprod = ((div(actualn, outnum) + min(1, rem(actualn, outnum))) * outnum) - actualn
    surplus = Map.put(surplus, prod, overprod + left_in_surplus)

    Enum.reduce(reqs, {0, surplus}, fn [rn, rin], {total_ore, surplus} ->
      in_need = rin * (div(actualn, outnum) + min(1, rem(actualn, outnum)))
      {ore_need, surplus} = case rn do
        "ORE" -> {in_need, surplus}
        _ -> produce(rn, in_need, reactions, surplus)
      end
      {total_ore + ore_need, surplus}
    end)
  end

  def search(react, guess, low, high, ore) do
    {needs, _left} = produce("FUEL", guess, react, %{})
    cond do
      high - low <= 1 ->
        low
      needs < ore ->
        low = guess
        guess = guess + div((high-low), 2)
        search(react, guess, low, high, ore)
      needs > ore ->
        high = guess
        guess = guess - div((high-low), 2)
        search(react, guess, low, high, ore)
      end
  end

  def calculate_fuel_from_ore(react, ore) do
     search(react, 1, 0, ore, ore)
  end

  def part1 do
    react = read_input("input14.txt")
    {needs, _left} = produce("FUEL", 1, react, %{})
    IO.puts needs
  end

  def part2 do
    read_input("input14.txt")
    |> calculate_fuel_from_ore(1000000000000)
    |> IO.puts()
  end
end
