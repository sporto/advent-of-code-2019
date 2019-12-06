import sequtils, math, strutils, sugar

const R = 367479 .. 893698

proc print_return[T](v: T): T =
    echo v
    v

proc digits(n: int): seq[int] =
    for ix in countdown(5, 0):
        let d = (floor (n.toFloat / pow(10, ix.toFloat))) mod 10
        result.add(d.toInt)

proc windows[T](s: seq[T]): seq[(T, T)] =
    zip(s[0 .. s.len - 2], s[1 .. s.len - 1])

proc hasTwo(s: seq[int]): bool =
    let first = s[0 .. 0]
    concat(first, s)
        .map(i => intToStr(i))
        .windows
        .map(proc (it: tuple[a: string, b: string]): string =
            if it[0] == it[1]:
                $(it[1])
            else:
                "/" & $(it[1])
        )
        .join()
        .split("/")
        .anyIt(it.len == 2)

proc noDecreasing(s: seq[int]): bool =
    s.windows.allIt(it[0] <= it[1])

proc isMatch(n: int): int =
    let s = digits(n)
    if s.hasTwo and s.noDecreasing:
        1
    else:
        0

proc main(): int =
    R.toSeq
        .map(isMatch)
        .foldl(a + b)

echo main()

# echo hasTwo(@[2, 1, 3, 3, 1])
