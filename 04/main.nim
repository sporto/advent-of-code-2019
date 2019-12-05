import sequtils, math

# const R = 367479 .. 893698
const R = 367479 .. 367480

proc digits(n: int): seq[int] =
    for ix in countdown(5, 0):
        let d = (floor (n.toFloat / pow(10, ix.toFloat))) mod 10
        result.add(d.toInt)


proc isMatch(n: int): int =
    let s = digits(n)
    echo s
    0

proc main(): int =
    R.toSeq
        .map(isMatch)
        .foldl(a + b)

echo main()
