import math, strutils, sugar
import sequtils

proc read_file(): seq[int] =
    let filename = "input.txt"
    let file = readFile(filename)
    file.splitLines().map(parseInt)


proc fuel_for_module(mass: float): float =
    (mass / 3).floor - 2

proc total_fuel_for_module(acc: float, mass: float): float =
    let res = mass.fuel_for_module
    if res > 0:
        total_fuel_for_module(acc + res, res)
    else:
        acc

proc calc(input: seq[int]): float =
    input
        .map(v => total_fuel_for_module(0, v.to_float))
        .foldl(a + b)

proc main(): float =
    let input = read_file()
    calc(input)

echo main()
