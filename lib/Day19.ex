defmodule Day19 do
  def part1 do
    prog =
      IC.read("input19.txt")
      |> IC.init()

    input = for y <- 0..49, x <- 0..49, do: [x,y]


    IO.write IO.ANSI.clear()
    input
      |> Enum.map(fn input = [x, y] ->
        %{stdout: out} =
          prog
          |> IC.start(input, [])
          |> IC.exec()
        o = hd(out)
          IO.write IO.ANSI.cursor(x, y)
          IO.write (if o == 0 do "." else "\#" end)
          o
        end)
      |> Enum.filter(&(&1 == 1))
      |> Enum.count()
      |> IO.puts
  end

  def probe(prog, p) do
    %{stdout: out} = IC.exec(IC.start(prog, p, []))
    hd(out)
  end

  def find(x, y, prog) do
    probes =
      [[x+99,y], [x+100, y], [x, y+99], [x, y+100]]
        |> Enum.map(fn p -> probe(prog, p) end)
    case probes do
      [1, 0, 1, 0] -> [x, y]
      [0, 0, 0, 0] -> find(x, y+1, prog)
      [1, 1, 1, 1] -> {:error, x, y}
      [1, 1, _, _] -> find(x+1, y, prog)
      [1, 0, _, _] -> find(x, y+1, prog)
      [_, _, 1, 0] -> find(x+1, y, prog)
    end
  end

  def part2 do
    prog =
      IC.read("input19.txt")
      |> IC.init()

    fromx = 5
    fromy = 5

    [x, y] = find(fromx, fromy, prog)

    IO.puts (x*10000+y)

  end
end
