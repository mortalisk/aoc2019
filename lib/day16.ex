defmodule Day16 do

  def input do
    File.read!("input16.txt")
    #"12345678888888888888888888888888"
    #"80871224585914546619083218645595"
    |> String.trim()
    |> String.graphemes()
    |> Enum.map(&String.to_integer/1)
  end

  def part1 do
    base = [0, 1, 0, -1]
    digits = input()
    n = Enum.count(digits)

    1..100
      |> Enum.reduce(digits, fn i, digs ->
        IO.puts i
        1..n
          |> Enum.map(fn di ->
            pattern =
              Stream.cycle(base)
              |> Stream.flat_map(&(Stream.repeatedly(fn -> &1 end) |> Enum.take(di)))
              |> Stream.drop(1)

            res =
              Stream.zip(digs, pattern)
              |> Stream.map(fn {d, p} -> d * p end)
              |> Enum.sum()

            rem(abs(res), 10)
          end)
        end)
        |> Enum.take(8)
        |> Enum.map(&Integer.to_string/1)
        |> Enum.join("")
        |> IO.inspect
  end

  def part2 do
    digits = input()
    n = Enum.count(digits)
    skip = digits |> Enum.take(7) |> Enum.map(&Integer.to_string/1) |> Enum.join("") |> String.to_integer()
    half = n*5000
    list = Stream.cycle(digits) |> Enum.take(n*5000)

    1..100
      |> Enum.reduce(list, fn _di, li ->
        sum = Enum.sum(li)
          li
            |> Enum.reduce({sum, []}, fn dig, {sum, digs} ->
              {sum - dig, [rem(abs(sum), 10)| digs]}
            end)
            |> elem(1)
            |> Enum.reverse()
      end)
      |> Enum.drop(skip - half)
      |> Enum.take(8)
      |> Enum.map(&Integer.to_string/1)
      |> Enum.join("")
      |> IO.inspect()

  end

end
