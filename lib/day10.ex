defmodule Day10 do

  def gcd(a, 0), do: a
  def gcd(0, b), do: b
  def gcd(a, b), do: gcd(b, rem(a,b))

  def minimize({x, y}) do
    divisor = abs(gcd(x, y))
    {div(x,divisor), div(y,divisor)}
  end

  def part1 do
    asteroids =
      File.stream!("input10.txt")
        |> Enum.with_index()
        |> Enum.flat_map(fn {line, y} ->
            String.graphemes(String.trim(line))
              |> Enum.with_index()
              |> Enum.map(fn {val, x} -> {{x, y}, val} end)
              |> Enum.filter(fn
                  {_, "."} -> false
                  {_, "\#"} -> true
                end)
          end)


      for {a = {ax, ay}, _} <- asteroids do
        lines =
          for {b = {bx, by}, _} <- asteroids, a != b do
            minimize({bx - ax, by - ay})
          end
          |> Enum.into(HashSet.new)
        {a, lines}
      end
      |> Enum.map(fn {_, lines} -> Enum.count(lines) end)
      |> Enum.max()
      |> IO.puts()

  end

  def angle({x, y}) do
    if x < 0 do
      :math.pi * 2 + :math.atan2(x, -y)
    else
      :math.atan2(x, -y)
    end
  end

  def dist2({ax, ay}, {bx, by}), do: :math.pow(ax - bx, 2) + :math.pow(ay - by, 2)

  def part2 do
    asteroids =
      File.stream!("input10.txt")
        |> Enum.with_index()
        |> Enum.flat_map(fn {line, y} ->
            String.graphemes(String.trim(line))
              |> Enum.with_index()
              |> Enum.map(fn {val, x} -> {{x, y}, val} end)
              |> Enum.filter(fn
                  {_, "."} -> false
                  {_, "\#"} -> true
                end)
          end)

     {p , lines} =
        for {a = {ax, ay}, _} <- asteroids do
          lines =
            for {b = {bx, by}, _} <- asteroids, a != b do
              vec = {bx - ax, by - ay}
              { angle(vec), b }
            end
              |> Enum.group_by(fn {dir, _} -> dir end)
              |> Enum.sort_by(fn {dir, _} -> dir end)
          {a, lines}
        end
        |> Enum.max_by(fn {_, lines} -> Enum.count(lines) end)

     lines
        |> Enum.at(199) |> IO.inspect()
        |> elem(1)
        |> Enum.sort_by(fn {_, point} -> dist2(p, point) end)
        |> Enum.at(0)
        |> elem(1)
        |> IO.inspect()

  end

end
