defmodule Day15 do

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
    #IO.puts "run #{inst}, #{inspect rest}, modes: #{inspect modes}"
    run([inst|rest], modes, p)
  end

  def perm_rep(list), do: perm_rep(list, length(list))
  def perm_rep([], _), do: [[]]
  def perm_rep(_,  0), do: [[]]
  def perm_rep(list, i) do
    for x <- list, y <- perm_rep(list, i-1), do: [x|y]
  end


  def walk({p, f}) do
    next = case f do
      1 -> [1, 3, 4]
      2 -> [2, 3, 4]
      3 -> [1, 2, 3]
      4 -> [1, 2, 4]
      _ -> [1, 2, 3, 4]
    end

    next
     |> Enum.map(fn dir ->
       p1 = %{stdout: [out1]} = exec(%{p|stdin: [dir]})
       p1 = %{p1 | stdout: []}
       case out1 do
          0 -> nil
          1 -> {p1 , dir}
          2 -> {:found, p1}
       end
     end)
     |> Enum.filter(&(&1 != nil))
  end

  def search(ps, d) do
    r = Enum.find(ps, nil, &(elem(&1, 0) == :found))

    case r do
      {:found, p} -> {d, p}
      _ ->
        newps = Enum.flat_map(ps, &walk/1)
        search(newps, d + 1)
    end

  end

  def search_all(ps, d) do
    IO.puts "depth: #{d}"
    r = Enum.count(ps)

    case r do
      0 -> d - 1
      _ ->
        newps = Enum.flat_map(ps, &walk/1)
        search_all(newps, d + 1)
    end

  end

  def part1() do

    program =
      read("input15.txt")
      |> init()
      |> start([], [])

    {depth, _prog} = search([{program, nil}], 0)

    IO.puts depth

  end

  def part2 do

    program =
      read("input15.txt")
      |> init()
      |> start([], [])

    {_depth, prog} = search([{program, nil}], 0)
    minutes = search_all([{prog, nil}], 0)

    IO.puts minutes

  end

end
