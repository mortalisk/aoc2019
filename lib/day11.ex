defmodule Day11 do

  def read(file) do
    File.read!(file) |> String.trim() |> String.split(",") |> Enum.map(&String.to_integer/1)
  end

  def init(program) do
    program
      |> Enum.with_index()
      |> Map.new(fn {k,v}->{v,k} end)
  end

  def start(program, stdin, stdout) do
    %{
      base: 0,
      prog: program,
      pos: 0,
      stdin: stdin,
      stdout: stdout,
      exited: false,
    }
  end

  def instruction(n), do: rem(n, 100)
  def parmodes(n), do: [rem(div(n,100), 10), rem(div(n,1000), 10), rem(div(n,10000), 10)]

  def read(%{prog: program}, n, 0), do: Map.get(program, n, 0)
  def read(_program, n, 1), do: n
  def read(%{prog: program, base: b}, n, 2), do: Map.get(program, b + n, 0)

  def readinst( %{prog: program}, n) do
    [program[n],
     Map.get(program, n+1, 0),
     Map.get(program, n+2, 0),
     Map.get(program, n+3, 0)]
  end

  def set(p = %{prog: program}, n, 0, val) do
    %{p | prog: Map.put(program, n, val)}
  end

  def set(p = %{prog: program, base: b}, n, 2, val) do
    %{p | prog: Map.put(program, b + n, val)}
  end

  def incpos(p = %{pos: pos}, n), do: %{p|pos: pos + n}

  def run([1, a, b, c], [am, bm, cm], program) do
    p = program |> set(c, cm, read(program, a, am)+read(program, b, bm))
    exec(incpos(p, 4))
  end

  def run([2, a, b, c], [am, bm, cm], program) do
    p = program |> set(c, cm, read(program, a, am)*read(program, b, bm))
    exec(incpos(p, 4))
  end

  def run([3, _a, _, _], _, program = %{stdin: []}) do
    program
  end

  def run([3, a, _, _], [am|_], program = %{stdin: [input|inrest]}) do
    p = program |> set(a, am, input) |> Map.put(:stdin, inrest)
    exec(incpos(p, 2))
  end

  def run([4, a, _, _], [am | _], program = %{stdout: out}) do
    exec(incpos(%{program|stdout: [read(program, a, am) | out]}, 2))
  end

  def run([5, a, b, _c], [am, bm, _cm], program) do
    if read(program, a, am) != 0 do
      exec(%{program | pos: read(program, b, bm)})
    else
      exec(incpos(program, 3))
    end
  end

  def run([6, a, b, _c], [am, bm, _cm], program) do
    if read(program, a, am) == 0 do
      exec(%{program | pos: read(program, b, bm)})
    else
      exec(incpos(program, 3))
    end
  end

  def run([7, a, b, c], [am, bm, cm], program) do
    if read(program, a, am) < read(program, b, bm) do
      exec(incpos(set(program, c, cm, 1), 4))
    else
      exec(incpos(set(program, c, cm, 0), 4))
    end
  end

  def run([8, a, b, c], [am, bm, cm], program) do
    if read(program, a, am) == read(program, b, bm) do
      exec(incpos(set(program, c, cm, 1), 4 ))
    else
      exec(incpos(set(program, c, cm, 0), 4))
    end
  end

  def run([9, a, _b, _c], [am|_], program = %{base: b}) do
    p = %{program | base: b + read(program, a, am)}
    exec(incpos(p, 2))
  end

  def run([99, _, _, _], _modes, p) do
    %{p|exited: true}
  end

  def run(_, _, _, _) do
    "error"
  end

  def exec(p = %{exited: true}), do: p
  def exec(p = %{pos: nextpos}) do
    [code | rest] = readinst(p, nextpos)
    inst = instruction(code)
    modes = parmodes(code)
    run([inst|rest], modes, p)
  end

  def permutations([]), do: [[]]
  def permutations(list) do
    for head <- list, tail <- permutations(list -- [head]), do: [head | tail]
  end

  def write(p = %{stdin: stdin}, val), do: %{p|stdin: [val|stdin]}

  def move([x, y], [xv, yv]), do: [x+xv, y+yv]
  def turn([xv, yv], 0), do: [-yv, xv]
  def turn([xv, yv], 1), do: [yv, -xv]

  def part1() do
    hull = %{}
    posstart = [0,0]
    dirstart = [0,1]
    black = 0
    white = 1

    program =
      read("input11.txt")
      |> init()
      |> start([], [])

    Stream.unfold({hull, program, posstart, dirstart}, fn {hull, p, pos, dirv} ->
      sensed = Map.get(hull, pos, black)
      p = write(p, sensed)
      case exec(p) do
        %{exited: true} -> nil
        p = %{stdout: [ dirout, paintout | rest]} ->
          hull = Map.put(hull, pos, paintout)
          p = %{p|stdout: rest}
          newdir = turn(dirv, dirout)
          newpos = move(pos, newdir)
          {pos, {hull, p, newpos, newdir}}
      end
    end)
    |> Enum.uniq()
    |> Enum.count()
    |> IO.puts()

  end

  def part2() do
    hull = %{}
    posstart = [0,0]
    dirstart = [0,1]
    black = 0
    white = 1

    program =
      read("input11.txt")
      |> init()
      |> start([], [])

    paintedhull =
      Stream.unfold({hull, program, posstart, dirstart}, fn {hull, p, pos, dirv} ->
        sensed = Map.get(hull, pos, white)
        p = write(p, sensed)
        case exec(p) do
          %{exited: true} -> nil
          p = %{stdout: [ dirout, paintout | rest]} ->
            hull = Map.put(hull, pos, case paintout do 0 -> " "; 1 -> "\#" end )
            p = %{p|stdout: rest}
            newdir = turn(dirv, dirout)
            newpos = move(pos, newdir)
            {hull, {hull, p, newpos, newdir}}
        end
      end)
      |> Enum.at(-1)

    minx = paintedhull |> Enum.reduce(10000, fn {[x, _], _}, minx -> min(x, minx) end)
    maxx = paintedhull |> Enum.reduce(-10000, fn {[x, _], _}, maxx -> max(x, maxx) end)
    miny = paintedhull |> Enum.reduce(10000, fn {[_, y], _}, miny -> min(y, miny) end)
    maxy = paintedhull |> Enum.reduce(-10000, fn {[_, y], _}, maxy -> max(y, maxy) end)

    for y <- maxy..miny do
      IO.puts("")
      for x <- minx..maxx do
        IO.write(Map.get(paintedhull, [x, y], "\#"))
      end
    end
  end

end
