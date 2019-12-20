defmodule Day7p do

  def read(file) do
    File.read!(file) |> String.trim() |> String.split(",") |> Enum.map(&String.to_integer/1)
  end

  def init(program) do
    program
      |> Enum.with_index()
      |> Map.new(fn {k,v}->{v,k} end)
  end

  def start(program) do
    Task.async(fn ->
      receive do
        {:start, outpid} ->
          #IO.puts "starting  #{inspect self} with #{inspect outpid}"
          %{lastout: out} = exec(%{
            prog: program,
            pos: 0,
            exited: false,
            stdout: outpid,
            lastout: nil
          })
          #IO.puts "exited"
          out
      end
    end)
  end

  def instruction(n), do: rem(n, 100)
  def parmodes(n), do: [rem(div(n,100), 10), rem(div(n,1000), 10)]

  def read(%{prog: program}, n, 0), do: program[n]
  def read(_program, n, 1), do: n

  def readinst( %{prog: program}, n) do
    [program[n],
     Map.get(program, n+1, nil),
     Map.get(program, n+2, nil),
     Map.get(program, n+3, nil)]
  end

  def set(p = %{prog: program}, n, val) do
    %{p | prog: Map.put(program, n, val)}
  end

  def incpos(p = %{pos: pos}, n), do: %{p|pos: pos + n}

  def run([1, a, b, c], [am, bm], program) do
    p = program |> set(c, read(program, a, am)+read(program, b, bm))
    exec(incpos(p, 4))
  end

  def run([2, a, b, c], [am, bm], program) do
    p = program |> set(c, read(program, a, am)*read(program, b, bm))
    exec(incpos(p, 4))
  end

  def run([3, a, _, _], _, program) do
    receive do
      input ->
        #IO.puts "received #{input}"
        program |> incpos(2) |> set(a, input) |> exec()
    end
  end

  def run([4, a, _, _], [am, _], program = %{stdout: out}) do
    val = read(program, a, am)
    send(out, val)
    exec(incpos(%{program|lastout: val}, 2))
  end

  def run([5, a, b, _c], [am, bm], program) do
    if read(program, a, am) != 0 do
      exec(%{program | pos: read(program, b, bm)})
    else
      exec(incpos(program, 3))
    end
  end

  def run([6, a, b, _c], [am, bm], program) do
    if read(program, a, am) == 0 do
      exec(%{program | pos: read(program, b, bm)})
    else
      exec(incpos(program, 3))
    end
  end

  def run([7, a, b, c], [am, bm], program) do
    if read(program, a, am) < read(program, b, bm) do
      exec(incpos(set(program, c, 1), 4))
    else
      exec(incpos(set(program, c, 0), 4))
    end
  end

  def run([8, a, b, c], [am, bm], program) do
    if read(program, a, am) == read(program, b, bm) do
      exec(incpos(set(program, c, 1), 4 ))
    else
      exec(incpos(set(program, c, 0), 4))
    end
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

    #IO.puts "exec #{inspect self} #{inst}"
    run([inst|rest], modes, p)
  end

  def permutations([]), do: [[]]
  def permutations(list) do
    for head <- list, tail <- permutations(list -- [head]), do: [head | tail]
  end

  def part1() do
    mem =
      read("input7.txt")
      |> init()

    result =
      permutations([0, 1, 2, 3, 4])
        |> Enum.map(fn phases ->
            [last| rest] =
              phases
              |> Enum.map(&({start(mem), &1}))
              |> Enum.reduce()
            end)
        |> Enum.max()
    IO.puts(result)
  end

  def part2() do
    mem =
      read("input7.txt")
      |> init()

    result =
      permutations([5, 6, 7, 8, 9])
        |> Task.async_stream(fn phases ->
            machines = Enum.map(phases, fn _ -> start(mem) end)
            machines |> Enum.with_index() |> Enum.each(fn {task, i} ->
              send(task.pid, {:start, Enum.at(machines, rem(i+1,5)).pid})
              send(task.pid, Enum.at(phases, i))
            end)
            first = machines |> Enum.at(0)
            send(first.pid, 0)
            last = machines |> Enum.at(4)
            Task.await(last)
          end)
        |> Enum.max()
    IO.inspect(result)
  end

end
