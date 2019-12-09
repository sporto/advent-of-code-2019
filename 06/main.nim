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

proc rec_get_distances_for(
        graph: Table[string, string],
        key: string,
        current_level: int,
        map: var Table[string, int]
    ): Table[string, int] =

    if graph.has_key(key):
        let orbiting = graph[key]
        map[orbiting] = current_level
        rec_get_distances_for(
            graph,
            orbiting,
            current_level + 1,
            map
        )
    else:
        map

proc get_distances_for(
        graph: Table[string, string],
        key: string
    ): Table[string, int] =
    var map = initTable[string, int]()
    rec_get_distances_for(
        graph,
        key,
        0,
        map
    )

proc main_a(): void =
    var graph = initTable[string, string]()

    let _ = get_input()
        .map(parse_line)
        .add_to_map(graph)

    var count = 0
    var cache = initCountTable[string]()

    for k in graph.keys:
        count += count_orbits(graph, cache, k)

    echo count

proc main_b(): void =
    var graph = initTable[string, string]()

    let _ = get_input()
        .map(parse_line)
        .add_to_map(graph)

    let you_map = get_distances_for(graph, "YOU")

    let san_map = get_distances_for(graph, "SAN")

    var combined_distances = initTable[string, int]()

    for k in you_map.keys:
        if san_map.has_key(k):
            let dist = you_map[k] + san_map[k]
            combined_distances[k] = dist

    echo combined_distances

    var smallest = 1_000_000
    for v in combined_distances.values:
        smallest = min(v, smallest)

    echo smallest

main_b()
