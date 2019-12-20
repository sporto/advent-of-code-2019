import strutils, sequtils, unicode, sugar, neo, math, options, algorithm, tables

const FILENAME = "input.txt"

type
    Coor = tuple[x: int, y: int]
    CoorWithDist = tuple[x: int, y: int, dist: float]
    AngleWithCoors = tuple[angle:float, coors: seq[CoorWithDist]]

proc parseLine(l: string): seq[bool] =
    l.toRunes.map(toUTF8).map(c => c == "#")

proc get_file_input(): seq[seq[bool]] =
    readFile(FILENAME)
        .splitLines
        .map(parseLine)

proc get_matrix(): Matrix[bool] =
    get_file_input().matrix

proc map_matrix[A,B](matrix: Matrix[A], target: var Matrix[B], fn: (coor: Coor, v: A) -> B): void =
    for t, v in matrix:
        let (row, col) = t
        let coor: Coor = (x: col, y: row)
        let new_value = fn(coor, v)
        target[row, col] = new_value

proc get_angle(origin: Coor, target: Coor): Option[float] =
    if origin == target:
        none(float)
    else:
        let delta_y = target.y - origin.y
        let delta_x = target.x - origin.x
        let angle = arctan2(delta_y.toFloat, delta_x.toFloat).radToDeg
        some(fmod(angle + 90 + 360, 360.0))

proc get_angles_matrix(origin: Coor, matrix: Matrix[bool]): Matrix[Option[float]] =
    let rows = matrix.column(0).len
    let cols = matrix.row(0).len
    var result_matrix = constantMatrix(rows, cols, none(float))
    matrix.map_matrix(result_matrix, proc (coor: Coor, v: bool): Option[float] =
        if v:
            get_angle(origin, coor)
        else:
            none(float)
    )
    result_matrix

proc distance_from(one: Coor, two: Coor): float =
    let x = two.x - one.x
    let y = two.y - one.y
    hypot(x.toFloat,y.toFloat)
    # math.sqrt((two.x - one.x)**2 + (two.y - one.y)**2) 

proc count(origin: Coor, matrix: Matrix[bool]): int =
    let v = matrix[origin.y, origin.x]
    if v:
        # if origin == (x:3,y:4):
        #     echo get_angles_matrix(origin, matrix)    
        get_angles_matrix(origin, matrix)
            .asVector
            .data
            .deduplicate
            .filterIt(it.isSome)
            .len
    else:
        0

proc main(): void =
    let matrix = get_matrix()
    let rows = matrix.column(0).len
    let cols = matrix.row(0).len
    var count_matrix = constantMatrix(rows, cols, 0)
    matrix.map_matrix(count_matrix, proc (coor: Coor, v: bool): int =
        count(coor, matrix)
    )

    var max = 0
    var coor = (x:0, y:0)
    for t, v in count_matrix:
        let (row, col) = t
        if v > max:
            max = v
            coor = (x:col, y:row)

    echo max
    echo coor

proc blast(list: seq[AngleWithCoors], current: int): CoorWithDist =
    # get first group
    let head: AngleWithCoors = list[0]
    let rest = list[1 .. list.len - 1]

    let head_coor = head.coors[0]
    let rest_coors = head.coors[1 .. head.coors.len - 1]
    if current == 200:
        head_coor
    else:
        let new_angle_with_coors: AngleWithCoors = (angle : head.angle, coors : rest_coors)
        let new_list = concat(rest, @[new_angle_with_coors])
        blast(new_list, current + 1)

proc main2(): void =
    let matrix = get_matrix()
    let rows = matrix.column(0).len
    let cols = matrix.row(0).len
    # let origin = (x:11,y:13)
    let origin = (x:17,y:23)
    let angles = get_angles_matrix(origin, matrix)
    var angles_map = initTable[float, seq[CoorWithDist]]()
    for t, v in angles:
        let (row, col) = t
        if v.isSome:
            let coor: Coor = (x: col, y: row)
            let dist = distance_from(origin, coor)
            let coor_dist = (x: col, y: row, dist : dist)
            let angle: float = v.get
            if not angles_map.hasKey(angle):
                angles_map[angle] = @[]
            angles_map[angle].add(coor_dist)

    # Sort values by distance
    var angles_map_sorted = initTable[float, seq[CoorWithDist]]()
    for k, v in angles_map.pairs:
        angles_map_sorted[k] = v.sortedByIt(it.dist)

    var angles_list = newSeq[AngleWithCoors]()
    for k, v in angles_map_sorted.pairs:
        let pair: AngleWithCoors = (angle : k, coors : v)
        angles_list.add(pair)

    let angles_list_sorted_by_angle = angles_list.sortedByIt(it.angle)
    # echo angles_list_sorted_by_angle
    let coor200 = blast(angles_list_sorted_by_angle, 1)
    echo coor200.x * 100 + coor200.y

main2()