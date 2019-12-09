defmodule Day5 do
  @input 5
  def read(file) do
    File.read!(file) |> String.trim() |> String.split(",") |> Enum.map(&String.to_integer/1)
  end

  def init(program) do
    program
      |> Enum.with_index()
      |> Map.new(fn {k,v}->{v,k} end)
  end

  def instruction(n) do
     rem(n, 100)
  end

  def parmodes(n) do
    [rem(div(n,100), 10), rem(div(n,1000), 10)]
  end

  def read(program, n, 0), do: program[n]
  def read(_program, n, 1), do: n

  def readinst( program, n) do
    [program[n],
     Map.get(program, n+1, nil),
     Map.get(program, n+2, nil),
     Map.get(program, n+3, nil)]
  end

  def set(program, n, val) do
    Map.put(program, n, val)
  end

  def run([1, a, b, c], [am, bm], nextpos, program) do
    p = program |> set(c, read(program, a, am)+read(program, b, bm))
    exec(nextpos + 4, p)
  end

  def run([2, a, b, c], [am, bm], nextpos, program) do
    p = program |> set(c, read(program, a, am)*read(program, b, bm))
    exec(nextpos + 4, p)
  end

  def run([3, a, _, _], _, nextpos, program) do
    p = program |> set(a, @input)
    exec(nextpos + 2, p)
  end

  def run([4, a, _, _], [am, _], nextpos, program) do
    IO.puts(read(program, a, am))
    exec(nextpos + 2, program)
  end

  def run([5, a, b, _c], [am, bm], nextpos, program) do
    if read(program, a, am) != 0 do
      exec(read(program, b, bm), program)
    else
      exec(nextpos + 3, program)
    end
  end

  def run([6, a, b, _c], [am, bm], nextpos, program) do
    if read(program, a, am) == 0 do
      exec(read(program, b, bm), program)
    else
      exec(nextpos + 3, program)
    end
  end

  def run([7, a, b, c], [am, bm], nextpos, program) do
    if read(program, a, am) < read(program, b, bm) do
      exec(nextpos + 4, set(program, c, 1))
    else
      exec(nextpos + 4, set(program, c, 0))
    end
  end

  def run([8, a, b, c], [am, bm], nextpos, program) do
    if read(program, a, am) == read(program, b, bm) do
      exec(nextpos + 4, set(program, c, 1))
    else
      exec(nextpos + 4, set(program, c, 0))
    end
  end

  def run([99, _, _, _], _modes, _nextpos, program) do
    read(program, 0, 0)
  end

  def run(_, _, _, _) do
    "error"
  end

  def exec(nextpos, program) do
    [code | rest] = readinst(program, nextpos)
    inst = instruction(code)
    modes = parmodes(code)
    run([inst|rest], modes, nextpos, program)
  end

  def part1() do
    program = read("input5.txt") |> init()
    result = exec(0, program)
    IO.puts(result)
  end

end
