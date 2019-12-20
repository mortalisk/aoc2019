defmodule Day20d2 do

  def solve do
    IO.write IO.ANSI.clear()
    map =
      File.stream!("input20.txt")
      |> Enum.with_index()
      |> Enum.flat_map(fn {l, li} ->
          String.to_charlist(l) |> Enum.with_index() |> Enum.map(fn {c, ci} ->
          IO.write IO.ANSI.cursor(li, (ci + 1))
          IO.write [c]
          {{ci, li}, c}
        end)
      end)
      |> Map.new()
      |> IO.inspect()
    space = 32
    portals =
      map
      |> Enum.reduce([], fn {pos = {x, y}, c}, acc ->
        here = c
        right = Map.get(map, {x+1, y}, space)
        left  = Map.get(map, {x-1, y}, space)
        above = Map.get(map, {x, y-1}, space)
        below = Map.get(map, {x, y+1}, space)
        if here > 64 do
          portal =
            cond do
              right == ?. -> {{left, here},  pos, {x+1, y}}
              left  == ?. -> {{here, right}, pos, {x-1, y}}
              above == ?. -> {{here, below}, pos, {x, y-1}}
              below == ?. -> {{above, here}, pos, {x, y+1}}
              true -> nil
            end
          if portal != nil do
            [portal|acc]
          else
            acc
          end
        else
          acc
        end
      end) |> IO.inspect()

    sport = {_, spos, start} =
      portals
        |> Enum.find(fn
          {{?A, ?A}, _, _} -> true
          _ -> false
        end)

    gport = {_, gpos, goal} =
      portals
        |> Enum.find(fn
          {{?Z, ?Z}, _, _} -> true
          _ -> false
        end)

    portals = portals |> Enum.reject(fn p -> p == sport or p == gport end)

    portal_by_key =
      portals
        |> Enum.group_by(fn {key, _pos, _open} -> key end)

    portal_by_pos =
      portals
        |> Enum.group_by(fn {_, pos, _} -> pos end)

    start = {start, 0}
    goal = {goal, 0}

    map = %{map|gpos => ?#, spos => ?# }
    visited = MapSet.new()
    d = bfs(map, portal_by_key, portal_by_pos, [start], 0, goal, visited)
    IO.puts d
  end

  def inside?({x, y}) do
    x > 19 and x < 100 and y > 19 and y < 100
  end

  def bfs(map, pbk, pbp, nodes, d, goal, visited) do
    if d < 21 do
      IO.puts "depth: #{d} nodes: #{Enum.count(nodes)}"
      IO.inspect nodes
    end

    visited = MapSet.union(visited, MapSet.new(nodes))

    nodes =
      nodes # transport
      |> Enum.map(fn p = {pos, level} ->
        #IO.puts "trasport #{inspect p}"
        case Map.get(pbp, pos) do
          nil -> p
          [{key, _pos, _outp}] ->
            if level == 0 and not inside?(pos)do
              nil
            else
              level =
                cond do
                  inside?(pos) -> level + 1
                  true -> level - 1
                end
              {_, _, opos} = Map.get(pbk, key) |> Enum.find(fn {_, otherpos, _} -> otherpos != pos end)
              {opos, level}
            end
        end
      end) |> Enum.reject(&(&1 == nil))

    found = nodes |> Enum.find(fn pos -> pos == goal end)
    if found != nil do
      d
    else
      ns =
        nodes |> Enum.flat_map( fn {{x, y}, lvl} ->
          [{0, 1}, {0, -1}, {1, 0}, {-1, 0}]
            |> Enum.map(fn {vx,vy} ->
              #IO.puts "x: #{x}, y: #{y}, lvl: #{lvl}"
              {{x + vx, y + vy}, lvl}
            end)
            |> Enum.filter(fn {newpos, _lvl} ->
              case Map.get(map, newpos) do
                ?# -> false #wall
                32 -> false #space
                _ -> true
              end
            end)
            |> Enum.reject(fn pos ->
              MapSet.member?(visited, pos)
            end)
        end)
      bfs(map, pbk, pbp, ns, d+1, goal, visited)
    end
  end
end
