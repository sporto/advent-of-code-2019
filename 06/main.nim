import strutils, sequtils, tables, sugar

const FILENAME = "input.txt"

proc get_input(): seq[string] =
    read_file(FILENAME)
        .splitlines()

proc parse_line(l: string): seq[string] =
    l.split(")")

proc add_to_map(records: seq[seq[string]], graph: var Table[string,
        string]): Table[string, string] =
    if records.len == 0:
        graph
    else:
        let first = records[0]
        let rest = records[1 .. records.len - 1]
        graph[first[1]] = first[0]
        add_to_map(rest, graph)

proc count_orbits(
    graph: Table[string, string],
    cache: var CountTable[string],
    key: string): int =
    if cache.has_key(key):
        cache[key]
    else:
        if graph.has_key(key):
            let count = count_orbits(graph, cache, graph[key]) + 1
            cache[key] = count
            count
        else:
            cache[key] = 0
            0


proc main(): void =
    var graph = initTable[string, string]()

    let _ = get_input()
        .map(parse_line)
        .add_to_map(graph)

    var count = 0
    var cache = initCountTable[string]()

    for k in graph.keys:
        count += count_orbits(graph, cache, k)

    echo count

main()
