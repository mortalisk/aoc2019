defmodule Day18 do

  def input do
    map =
      File.stream!("input18t.txt")
      |> Enum.map(&String.graphemes/1)
      |> Enum.with_index()
      |> Enum.flat_map(fn {l, li} ->
        Enum.with_index(l)
          |> Enum.map(fn {<<p>> <> _, pi} ->
              {{pi, li}, p}
          end)
      end)
    |> Map.new() |> IO.inspect

    start = map
      |> Enum.find(fn
        {_, ?@} -> true
        _ -> false
      end) |> IO.inspect
    {start, map}
  end

  @alldirs [{0, 1},{0, -1},{1, 0},{-1, 0}]


  def not_dirs(ds) do
    @alldirs
      |> Enum.reject(fn dir -> Enum.member?(ds, dir) end)
  end

  def not_dirs2(ds, pos, map) do
    @alldirs
      |> Enum.reject(fn dir -> Enum.member?(ds, dir) end)
      |> Enum.reject(fn dir -> map[add(pos, dir)] == ?# end)
  end
  def sub({x, y}, {bx, by}), do: {x-bx, y-by}

  def add({x, y}, {bx, by}), do: {x+bx, y+by}


  def iter_path(a = {map, pos, prevposs, keys, target_key_num}) do
    keyc = Enum.count(keys)
    #IO.puts "keys: #{keyc}, target: #{target_key_num}"
    if keyc == target_key_num do
     [{:found, a}]
    else

      cur = map[pos]
      cond do
        cur == ?# ->
          [] # outside of bounds, no results
        cur > 64 and cur < 91 -> # inside door
          lowerc = cur + (?a - ?A)
          if MapSet.member?(keys, lowerc) do # have key
            backs = prevposs |> Enum.map(fn prevpos -> sub(prevpos, pos) end)

            not_dirs(backs) |> Enum.map(fn dir ->
              {map, add(pos, dir), [pos], keys, target_key_num}
            end)
          else
            [] # dont have key, invalid pos, no results
          end
        cur >= 97 -> # pick up key, and try all directions from here
          keys = MapSet.put(keys, cur)
          map = Map.put(map, pos, ?.)
          @alldirs |> Enum.map(fn dir ->
            {map, add(pos, dir), [pos], keys, target_key_num}
          end)
        cur == ?. -> # continue, but dont go back
          backs = prevposs |> Enum.map(fn prevpos -> sub(prevpos, pos) end)
          not_dirs(backs) |> Enum.map(fn dir ->
            {map, add(pos, dir), [pos], keys, target_key_num}
          end)

      end
    end
  end

  def remove_dups(nodes) do
    nodes
      |> Enum.group_by(fn {_, pos, _, keys, _} -> {pos, keys} end)
      |> Enum.map(fn {_, sames} ->
          Enum.reduce(sames, fn
            {map, pos, prevposs, keys, target_key_num},
            {_mapa, _posa, prevpossa, _keysa, _target_key_numa} ->
              {map, pos, prevposs ++ prevpossa, keys, target_key_num}
            end)
       end)
  end

  def find_path(nodes, d) do
    IO.puts("Depth: #{d} Nodes: #{Enum.count(nodes)}")
    r = Enum.find(nodes, &(elem(&1, 0) == :found))
    if r != nil do
      d - 1
    else
      nodes = remove_dups(nodes)
      #if Enumerable.impl_for(nodes) == nil do IO.inspect nodes end
      ns = Enum.flat_map(nodes, &iter_path/1)
      find_path(ns, d+1)
    end
  end



  def part1 do
    {{startpos, _}, map} = input()
    map = Map.put(map, startpos, ?.)
    target = map
      |> Enum.reject(fn {_,c} -> c < 97 end)
      |> Enum.count()

    d = find_path([{map, startpos, [], MapSet.new(), target}], 0)

    IO.puts "end: #{d}"
  end

  def remove_dups2(nodes) do
    nodes
      |> Enum.group_by(fn {_ , _, pos, _, keys, _} -> {pos, keys} end)
      |> Enum.map(fn
        {_, [o]} -> o
        {_, sames} ->
          Enum.reduce(sames, fn
            {r, map, pos, prevposs, keys, steps},
            {_r, _mapa, _posa, prevposs2, _keysa, steps2} ->
              if steps < steps2 do
                {r, map, pos, prevposs, keys, steps}
              else
                {r, map, pos, prevposs2, keys, steps2}
              end
            end)
       end)
  end

  def has_key?(r, c, others) do
    others
      |> Enum.reject(fn
        [] -> true
        [{rr, _, _, _, _, _}|_] -> rr == r
      end)
      |> Enum.any?(fn ol ->
        ol |> Enum.find( fn o ->
          keys = elem(o, 4)
          Enum.member?(keys, c)
        end)
      end)
  end

  def iter_path2(a = {r, map, pos, prevposs, keys, steps}, others) do

      cur = map[pos]
      cond do
        cur == ?# ->
          [] # outside of bounds, no results
        cur > 64 and cur < 91 -> # inside door
          lowerc = cur + (?a - ?A)
          if has_key?(r, lowerc, others) do # have key
            backs = prevposs |> Enum.map(fn prevpos -> sub(prevpos, pos) end)

            not_dirs2(backs, pos, map) |> Enum.map(fn dir ->
              {r, map, add(pos, dir), [pos], keys, steps+1}
            end)
          else
            [a] # dont have key, wait
          end
        cur >= 97 -> # pick up key, and try all directions from here
          keys = MapSet.put(keys, cur)
          map = Map.put(map, pos, ?.)
          not_dirs2(@alldirs, pos, map) |> Enum.map(fn dir ->
            {r, map, add(pos, dir), [pos], keys, steps+1}
          end)
        cur == ?. -> # continue, but dont go back
          backs = prevposs |> Enum.map(fn prevpos -> sub(prevpos, pos) end)
          not_dirs2(backs, pos, map) |> Enum.map(fn dir ->
            {r, map, add(pos, dir), [pos], keys, steps+1}
          end)

      end
    end

    def find_path2(nodes, d, target) do
      IO.puts("Depth: #{d} Nodes: #{Enum.count(nodes)}")
      if d == 20 do d else

      nodes = remove_dups2(nodes)

      others =
        Enum.group_by(nodes, &(elem(&1, 0)))
        |> Enum.map(fn {r, ns} ->
          IO.inspect(r)
          Enum.sort_by(
           ns,
           fn {_, _, _, _, keys, steps} -> {keys, steps} end,
           fn {c, s}, {c2, s2} -> c > c2 or (c == c2 and s >= s2) end)
        end)

      {keys, steps} =
        others
        |> Enum.map(&(Enum.at(&1, 0)))
        |> Enum.reduce({MapSet.new(), 0}, fn {_r, _map, _pos, _prevposs, keys, steps}, {ks, stps} ->
          {MapSet.union(keys, ks), stps + steps} # sum all keys and steps
        end)
      if Enum.count(keys) == target do
        steps
      else
        ns = Enum.flat_map(nodes, &(iter_path2(&1, others)))
        find_path2(ns, d+1, target)
      end
    end
    end


  def part2 do
    {{startpos, _}, map} = input()

    map = Map.put(map, startpos, ?#)
    map = Map.put(map, add(startpos, {0,1}), ?#)
    map = Map.put(map, add(startpos, {0,-1}), ?#)
    map = Map.put(map, add(startpos, {1,0}), ?#)
    map = Map.put(map, add(startpos, {-1,0}), ?#)

    starta = add(startpos, {1, 1})
    startb = add(startpos, {1, -1})
    startc = add(startpos, {-1, -1})
    startd = add(startpos, {-1, 1})

    start =
       [{:a, map, starta, [], MapSet.new(), 0},
        {:b, map, startb, [], MapSet.new(), 0},
        {:c, map, startc, [], MapSet.new(), 0},
        {:d, map, startd, [], MapSet.new(), 0} ]

    target = map
      |> Enum.reject(fn {_,c} -> c < 97 end)
      |> Enum.count()

    d = find_path2(start, 0, target)

    IO.puts "end: #{d}"
  end
end
