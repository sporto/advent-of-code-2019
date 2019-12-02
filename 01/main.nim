import math, strutils
import sequtils

proc read_file(): seq[int] =
    let filename = "input.txt"
    let file = readFile(filename)
    file.splitLines().map(parseInt)


proc fuel_for_module(mass: int): float =
    (mass / 3).floor - 2

proc calc(input: seq[int]): float =
    input
        .map(fuel_for_module)
        .foldl(a + b)

proc main(): float =
    let input = read_file()
    calc(input)



# echo fuel_for_module(100756)

echo main()
