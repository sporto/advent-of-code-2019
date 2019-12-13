import unicode, strutils, sequtils, tables

const WIDE = 25
const TALL = 6
const DIGITS_IN_LAYER = WIDE * TALL

const FILENAME = "input.txt"

proc read_file(): seq[int] =
    let file = readFile(FILENAME)
    file
        .toRunes
        .map(toUTF8)
        .map(parseInt)

proc count_digits(layer: seq[int]): CountTable[int] =
    # var table = initCountTable[int]()
    layer.toCountTable


proc main(): void =
    let all = read_file()
    let layer_count = all.len / DIGITS_IN_LAYER
    let layers = all.distribute(layer_count.to_int)
    let counts = layers.map(count_digits)
    var fewest = counts[0]
    for c in counts:
        if c[0] < fewest[0]:
            fewest = c
    echo fewest
    echo fewest[1] * fewest[2]

main()