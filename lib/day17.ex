defmodule Day17 do
def create_map do
  prog =
    Day15.read("input17.txt")
    |> Day15.init()
    |> Day15.start([], [])

  %{stdout: out} = Day15.exec(prog)
  lines =
    out
    |> Enum.reverse()
    |> Enum.chunk_by(&(&1 == ?\n))
    |> Enum.reject(&(Enum.member?(&1, ?\n)))
    #> IO.inspect( limit: :infinity)

  map = lines
    |> Enum.with_index()
    |> Enum.flat_map(fn {l, li} ->
      Enum.with_index(l)
        |> Enum.map(fn {p, pi} ->
            {{pi, li}, p}
        end)
    end)
  |> Map.new()
end

  def part1 do

    map = create_map()
    map
      |> Enum.filter(fn {{x, y}, p} ->
        p == ?# and
          Map.get(map, {x - 1, y}, nil) == ?# and
          Map.get(map, {x + 1, y}, nil) == ?# and
          Map.get(map, {x, y - 1}, nil) == ?# and
          Map.get(map, {x, y + 1}, nil) == ?#
      end)
      |> Enum.map(fn {{x, y}, _} ->
        x * y
      end)
      |> Enum.sum()
      |> IO.puts()

  end

  def left( {x, y}), do: {y, -x}
  def right({x, y}), do: {-y, x}
  def add({x, y}, {x1, y1}), do: {x+x1, y+y1}

  def res(path, a, b, c) do
    if Enum.join(a, "") |> String.length() > 20
      or Enum.join(b, "") |> String.length()  > 20
      or Enum.join(c, "") |> String.length()  > 20 do
      nil
    else
      Enum.reduce_while(1..11, {path, []}, fn n, {path, r} ->
        cond do
          n == 11 -> {:halt, r}
          Enum.count(path) == 0 and Enum.count(r) <= 10 -> {:halt, r}
          true ->
            cond do
              List.starts_with?(path, a) -> {:cont, {Enum.drop(path, Enum.count(a)), [?A|r]}}
              List.starts_with?(path, b) -> {:cont, {Enum.drop(path, Enum.count(b)), [?B|r]}}
              List.starts_with?(path, c) -> {:cont, {Enum.drop(path, Enum.count(c)), [?C|r]}}
              true -> {:halt, nil}
            end
        end
      end)
    end
  end

  def part2 do
    map = create_map()

    {pos, _} = map |> Enum.find(fn
        {_, ?^} -> true
        _ -> false
      end)

    dir = {0,-1}

    path =
      Stream.unfold({pos, dir}, fn  {pos, dir} ->
        l = left(dir)
        r = right(dir)
        lp = add(pos, l)
        rp = add(pos, r)

        moves = Stream.unfold(pos, fn pos ->
          fp = add(pos, dir)
          if Map.get(map, fp) == ?# do {fp, fp} else nil end
        end)
        num = Enum.count(moves)

        cond do
          num > 0                -> {num, {Enum.at(moves, -1), dir}}
          Map.get(map, lp) == ?# -> {"L", {pos, l}}
          Map.get(map, rp) == ?# -> {"R", {pos, r}}
          true                   -> nil
        end
      end)
      |> Enum.to_list()

    l = Enum.count(path)

    [input|_] =
      for a <- 1..15,
      c <- (l-16)..(l-1),
      b <- (a+1)..(c-2),
      b2 <- (b+1)..(c-1),
      suba = Enum.take(path, a),
      subb = Enum.drop(path, b) |> Enum.take(b2 - b),
      subc = Enum.drop(path, c),
      r = res(path, suba, subb, subc),
      r != nil do
        r = (Enum.reverse(r) |> Enum.intersperse(?,) |> to_string()) <> "\n"
          <> Enum.join(suba, ",") <> "\n"
          <> Enum.join(subb, ",") <> "\n"
          <> Enum.join(subc, ",") <> "\nn\n"
        to_charlist(r)
       end

    mem =
      Day15.read("input17.txt")
      |> Day15.init()

    # this was the manual solution input = 'A,B,A,B,C,B,C,A,C,C\nR,12,L,10,L,10\nL,6,L,12,R,12,L,4\nL,12,R,12,L,6\nn\n'

    prog2 = Day15.start(Map.put(mem, 0 , 2), input, [])

    %{stdout: [lastout|_]} = Day15.exec(prog2)
    IO.puts lastout

  end
end
