import strutils, sequtils, unicode, sugar, neo, math, options

const FILENAME = "example1.txt"

type
    Coor = tuple[x: int, y: int]

proc parseLine(l: string): seq[bool] =
    l.toRunes.map(toUTF8).map(c => c == "#")

proc get_file_input(): seq[seq[bool]] =
    readFile(FILENAME)
        .splitLines
        .map(parseLine)

# proc row_count[A](m: Matrix[A]): int =
#     matrix.column(0).len

# proc col_count[A](m: Matrix[A]): int =
#     matrix.row(0).len

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
        some(angle)

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

proc count(origin: Coor, matrix: Matrix[bool]): int =
    let v = matrix[origin.y, origin.x]
    if v:
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

    echo count_matrix

main()