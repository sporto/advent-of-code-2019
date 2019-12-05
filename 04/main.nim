import sequtils, math

const R = 367479 .. 893698

proc digits(n: int): seq[int] =
    for ix in countdown(5, 0):
        let d = (floor (n.toFloat / pow(10, ix.toFloat))) mod 10
        result.add(d.toInt)

proc windows(s: seq[int]): seq[(int, int)] =
    zip(s[0 .. s.len - 2], s[1 .. s.len - 1])

proc hasTwo(s: seq[int]): bool =
    s.windows.anyIt(it[0] == it[1])


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
