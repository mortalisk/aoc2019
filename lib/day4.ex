
defmodule Day4 do

  def input do
    193651..649729
      |> Stream.map(&Integer.to_string/1)
      |> Stream.map(&String.graphemes/1)
      |> Stream.map(fn chars -> Enum.map(chars, &String.to_integer/1) end)
  end

  def increasing([_]), do: true
  def increasing([a, b | rest]), do: a <= b and increasing([b|rest])
  def has_double([a, b]), do: a == b
  def has_double([a| rest] = [a, b| _]), do: a == b or has_double(rest)

  def has_strict_double(prev, [a, b]), do: prev != a and a == b
  def has_strict_double(prev, [_| rest] = [a, b, c| _]), do: (prev != a and a == b and b != c) or has_strict_double(a, rest)
  def has_strict_double(digits), do: has_strict_double(-1, digits)


  def part1 do
    input()
      |> Stream.filter(&increasing/1)
      |> Stream.filter(&has_double/1)
      |> Enum.count()
  end

  def part2 do
    input()
      |> Stream.filter(&increasing/1)
      |> Stream.filter(&has_strict_double/1)
      |> Enum.count()
  end
end
