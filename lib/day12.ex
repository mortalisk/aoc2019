defmodule Day12 do
  def add([x, y, z], [x1, y2, z2]), do: [x+x1, y+y2, z+z2]

  def velchange({a, b}) when a < b, do: 1
  def velchange({a, b}) when a == b, do: 0
  def velchange({a, b}) when a > b, do: -1

  def updatevel(vel, a, b) do
    changes = Enum.zip(a,b) |> Enum.map(&velchange/1)
    add(vel, changes)
    #Enum.zip(vel, changes) |> Enum.map(&add/1)
  end

  def updatemoons(moons) do
     moons |> Enum.map(fn [p, v] ->
       newvel =
         moons |> Enum.reduce(v, fn [op, _ov], v ->
           updatevel(v, p, op)
         end)
       #IO.inspect(newvel)
       newpos = add(p, newvel)
       [newpos, newvel]
     end)
  end

  def part1 do
    moons =
      File.stream!("input12.txt")
        |> Enum.map(&String.trim/1)
        |> Enum.map(&(String.replace(&1, ~r/[<>x=y=z=]/, "")))
        |> Enum.map(&(String.split(&1, ", ")))
        |> Enum.map(fn p -> Enum.map(p, &String.to_integer/1) end)
        |> Enum.map(fn p -> [p, [0,0,0]] end)

    newmoons = 0..999 |> Enum.reduce(moons, fn _, m -> updatemoons(paint(m)) end)

    newmoons
      |> Enum.map(fn [p, v] ->
        p = Enum.map(p, &abs/1) |> Enum.sum()
        k = Enum.map(v, &abs/1) |> Enum.sum()
        p * k
      end)
      |> Enum.sum()
      |> IO.inspect
  end

  def gcd(a, 0), do: a
	def gcd(0, b), do: b
	def gcd(a, b), do: gcd(b, rem(a,b))

	def lcm(0, 0), do: 0
	def lcm(a, b), do: div((a*b),gcd(a,b))

  def ns(moons, n) do
    Enum.map(moons, fn [p, v] -> [Enum.at(p, n), Enum.at(v, n)] end)
  end

  def paint(moons) do
    :timer.sleep(200)
    IO.puts IO.ANSI.clear()
    for [[x, y, _z], _] <- moons do
      IO.write IO.ANSI.cursor(max(0,y+30), 0)
      IO.write Stream.cycle(' ') |> Enum.take(x + 40)
      IO.write "\#"
    end

    IO.write IO.ANSI.cursor(0, 0)
    moons
  end

  def repeat(moons, npos) do
    poss = ns(moons, npos)

    Stream.unfold([1, updatemoons(moons)], fn [n, ms] ->
      if poss == ns(ms, npos) do
        nil
      else
        {n + 1, [n+1, updatemoons(ms)]}
      end
    end) |> Enum.at(-1)
  end

  def part2 do
    moons =
      File.stream!("input12.txt")
        |> Enum.map(&String.trim/1)
        |> Enum.map(&(String.replace(&1, ~r/[<>x=y=z=]/, "")))
        |> Enum.map(&(String.split(&1, ", ")))
        |> Enum.map(fn p -> Enum.map(p, &String.to_integer/1) end)
        |> Enum.map(fn p -> [p, [0,0,0]] end)

    xr = repeat(moons, 0)
    yr = repeat(moons, 1)
    zr = repeat(moons, 2)
    IO.puts(lcm(xr, lcm(yr, zr)))
  end

  def test do


  end
end
