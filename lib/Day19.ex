defmodule Day19 do
  def create_map do
    prog =
      IC.read("input17.txt")
      |> IC.init()
      |> IC.start([], [])

    %{stdout: out} = IC.exec(prog)
    lines =
      out
      |> Enum.reverse()
      |> Enum.chunk_by(&(&1 == ?\n))
      |> Enum.reject(&(Enum.member?(&1, ?\n)))

    lines
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
    if rem(x, 1000) == 0 do IO.puts "try #{x}, #{y} -> #{inspect probes}" end
    case probes do
      [1, 0, 1, 0] -> [x, y]
      [0, 0, 0, 0] -> find(x, y+1, prog)
      [1, 1, 1, 1] -> {:error, x, y}
      [1, 1, _, _] -> find(x+1, y, prog)
      [1, 0, _, _] -> find(x, y+1, prog)
      [_, _, 1, 0] -> find(x+1, y, prog)
      #[_, _, 0, 0] -> find(x, y+1, prog)
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

    # input = for x <- fromx..(fromx + 200), y <- fromy..(fromy + 100), do: [x,y]
    #
    # IO.write IO.ANSI.clear()
    # map =
    #   input
    #   |> Enum.map(fn input = [x, y] ->
    #     %{stdout: out} =
    #       prog
    #       |> IC.start(input, [])
    #       |> IC.exec()
    #     o = hd(out)
    #       IO.write IO.ANSI.cursor(y-fromy, x-fromx)
    #       IO.write (if o == 0 do "." else "\#" end)
    #       {{x, y}, o}
    #     end)
    #     |> Map.new()
        #|> IO.inspect()

  end
end
