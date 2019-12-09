defmodule Day8 do

  def part1() do
    image =
      File.read!("input8.txt")
        |> String.trim()
        |> String.graphemes()
        |> Enum.map(&String.to_integer/1)
        |> Enum.chunk_every(25*6)
        |> IO.inspect()

    layer = image
      |> Enum.min_by(fn l -> Enum.count(l, &(&1 == 0)) end)

    ones = Enum.count(layer, &(&1 == 1))
    twos = Enum.count(layer, &(&1 == 2))

    IO.puts ones * twos
  end

  def part2() do
      File.read!("input8.txt")
        |> String.trim()
        |> String.graphemes()
        |> Enum.map(&String.to_integer/1)
        |> Enum.chunk_every(25*6)
        |> Enum.reverse()
        |> Enum.reduce(fn layer, im ->
            Enum.zip(im, layer)
             |> Enum.map(fn
              {_, 0} -> 0
              {_, 1} -> 1
              {a, 2} -> a
             end)
            end)
        |> Enum.chunk_every(25)
        |> Enum.map(fn row ->
              Enum.map(row, fn
               0 -> " "
               1 -> "*"
              end)
              |> Enum.join("")
           end)
        |> Enum.each(&IO.inspect/1)
  end
end
