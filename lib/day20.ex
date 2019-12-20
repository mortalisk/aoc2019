defmodule Day20 do

  def part1 do
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


    portal_by_key =
      portals
        |> Enum.group_by(fn {key, _pos, _open} -> key end)

    portal_by_pos =
      portals
        |> Enum.group_by(fn {_, pos, _} -> pos end)

    {_, spos, start} =
      portals
        |> Enum.find(fn
          {{?A, ?A}, _, _} -> true
          _ -> false
        end)

    {_, gpos, goal} =
      portals
        |> Enum.find(fn
          {{?Z, ?Z}, _, _} -> true
          _ -> false
        end)

    map = %{map|gpos => ?#, spos => ?# }
    visited = MapSet.new()
    d = bfs(map, portal_by_key, portal_by_pos, [start], 0, goal, visited)
    IO.puts d
  end


  def bfs(map, pbk, pbp, nodes, d, goal, visited) do
    IO.puts "depth: #{d} goal: #{inspect goal}"
    nodes =
      nodes # transport
      |> Enum.map(fn pos ->
        case Map.get(pbp, pos) do
          nil -> pos
          [{key, _pos, _outp}] ->
            {_, _, opos} = Map.get(pbk, key) |> Enum.find(fn {_, otherpos, _} -> otherpos != pos end)
            opos
        end
      end)
    visited = MapSet.union(visited, MapSet.new(nodes))

    found = nodes |> Enum.find(fn pos -> pos == goal end)
    if found != nil do
      d
    else
      ns =
        nodes |> Enum.flat_map( fn {x, y} ->
          [{0, 1}, {0, -1}, {1, 0}, {-1, 0}]
          |> Enum.map(fn {vx,vy} ->
            {x + vx, y + vy}
          end)
          |> Enum.filter(fn newpos ->
            case Map.get(map, newpos) do
              ?# -> false #wall
              32 -> false #space
              _ -> true
            end
          end)
          |> Enum.reject(fn newpos ->
            MapSet.member?(visited, newpos)
          end)
        end)
      bfs(map, pbk, pbp, ns, d+1, goal, visited)
    end
  end
end
