defmodule Day17 do
  def part1 do
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

  def part2 do
    mem =
      Day15.read("input17.txt")
      |> Day15.init()
    prog1 = Day15.start(mem, [], [])

    input = 'A,B,A,B,C,B,C,A,C,C\nR,12,L,10,L,10\nL,6,L,12,R,12,L,4\nL,12,R,12,L,6\nn\n'

    prog2 = %{prog: %{0 => m0}} = Day15.start(Map.put(mem, 0 , 2), input, [])
    IO.inspect m0

    %{stdout: [lastout|_]} = Day15.exec(prog2)
    #points = Enum.reverse(out)
    IO.puts lastout

  end
end
