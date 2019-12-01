defmodule Day1 do

  def part1 do
    "input1.txt"
    |> File.stream!()
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.to_integer/1)
    |> Enum.map(fn x -> div(x, 3) - 2 end)
    |> Enum.sum()
    |> IO.puts()
  end

  def part2 do
    "input1.txt"
    |> File.stream!()
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.to_integer/1)
    |> Enum.map(fn x ->
      Stream.unfold(x, fn x_ ->
        fuel = div(x_, 3) - 2
        if fuel <= 0 do
          nil
        else
          {fuel, fuel}
        end
      end)
      |> Enum.sum()
    end)
    |> Enum.sum()
    |> IO.puts()
  end
end
