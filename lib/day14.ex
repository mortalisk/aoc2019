defmodule Day14 do

  def parse_chem(chem) do
    [pn, pname] = String.split(chem,  " ")
    pnum = String.to_integer(pn)
    [pname, pnum]
  end

  def produce(prod, n, reactions, leftover) do
    {outnum, reqs = [[frn, frin]|_]} = reactions[prod]
    left = Map.get(leftover, prod, 0)
    actualn = n - min(left, n)
    left = left - min(left, n)
    leftover = Map.put(leftover, prod, left)
    extraprod = ((div(actualn, outnum) + min(1, rem(actualn, outnum))) * outnum) - actualn
    leftover = Map.put(leftover, prod, extraprod + left)

    if frn == "ORE" do
      ore_need = frin * (div(actualn,outnum) + min(1, rem(actualn, outnum)))
      {ore_need, leftover}
    else
      reqs |> Enum.reduce({0, leftover}, fn [rn, rin], {oneed, left} ->
        in_need = rin * (div(actualn, outnum) + min(1, rem(actualn, outnum)))
        {ore_need, leftover} = produce(rn, in_need, reactions, left)
        {oneed + ore_need, leftover}
      end)
    end
  end

  def part1 do
    react =
      "input14.txt"
      |> File.stream!()
      |> Stream.map(&String.trim/1)
      |> Enum.reduce(%{}, fn s, acc ->
        [req, p] = String.split(s, " => ")
        [pname, pnum] = parse_chem(p)
        requirements = req |> String.split(", ") |> Enum.map(&parse_chem/1)
        Map.put(acc, pname, {pnum, requirements})
      end) #|> IO.inspect

    {needs, _left} = produce("FUEL", 1, react, %{})
    IO.puts needs
  end

  def search(guess, low, high, react) do
    ore = 1000000000000
    {needs, _left} = produce("FUEL", guess, react, %{})
    cond do
      high - low <= 1 ->
        low
      needs < ore ->
        low = guess
        guess = guess + div((high-low), 2)
        search(guess, low, high, react)
      needs > ore ->
        high = guess
        guess = guess - div((high-low), 2)
        search(guess, low, high, react)
      end
  end

  def part2 do
    react =
      "input14.txt"
      |> File.stream!()
      |> Stream.map(&String.trim/1)
      |> Enum.reduce(%{}, fn s, acc ->
        [req, p] = String.split(s, " => ")
        [pname, pnum] = parse_chem(p)
        requirements = req |> String.split(", ") |> Enum.map(&parse_chem/1)
        Map.put(acc, pname, {pnum, requirements})
      end) #|> IO.inspect

    IO.puts search(0, 0, 10000000, react)
  end
end
