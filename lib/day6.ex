defmodule Day6 do

  def read(file) do
    File.stream!(file)
      |> Stream.map(&String.trim/1)
      |> Stream.map(&(String.split(&1, ")")))
      |> Stream.map(fn [a, b] -> {b, a} end)
      |> Map.new()
  end

  def depth(graph, node, count) do
    if Map.has_key?(graph, node) do
      val = graph[node]
      depth(graph, val, count+1)
    else
      count
    end
  end

  def path(graph, node, target, p) do
    next = graph[node]
    if next != target do
      path(graph, next, target, [next | p])
    else
      p
    end
  end

  def pathtocommon(graph, node, otherpath, p) do
    if Enum.member?(otherpath, node) do
      p
    else
      next = graph[node]
      pathtocommon(graph, next , otherpath, [next|p])
    end
  end

  def part1() do
    graph = read("input6.txt")
    graph
      |> Map.keys()
      |> Enum.map(&(depth(graph, &1, 0)))
      |> Enum.sum()
      |> IO.puts()
  end

  def part2() do
    graph = read("input6.txt")
    path = path(graph, "YOU", "COM", [])
    path1 = pathtocommon(graph, "SAN", path, [])
    path2 = path(graph, "YOU", hd(path1), [])
    IO.puts Enum.count(path1) + Enum.count(path2) -1
  end

end
