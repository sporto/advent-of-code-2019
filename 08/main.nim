import unicode, strutils, sequtils, tables, sugar

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
    layer.toCountTable

proc get_layers(): seq[seq[int]] =
    let all = read_file()
    let layer_count = all.len / DIGITS_IN_LAYER
    all.distribute(layer_count.to_int)

proc main_1(): void =
    let layers = get_layers()
    let counts = layers.map(count_digits)
    var fewest = counts[0]
    for c in counts:
        if c[0] < fewest[0]:
            fewest = c
    echo fewest
    echo fewest[1] * fewest[2]

proc flatten(layers: seq[seq[int]], image: seq[int]): seq[int] =
    var new_image = newSeq[int](image.len)
    if layers.len == 0:
        image
    else:
        let layer = layers[0]
        for ix, _ in layer:
            if image[ix] == 2: # transparent
                new_image[ix] = layer[ix]
            else:
                new_image[ix] = image[ix]
        flatten(layers[1 .. layers.len - 1], new_image)

proc print_line(line: seq[int]) : void=
    var res = ""
    for c in line:
        if c == 0:
            res.add(" ")
        else:
            res.add("▮")
    echo res

proc main_2(): void =
    let layers = get_layers()
    let image = layers.flatten(layers[0])
    let lines = image.distribute(TALL)
    for l in lines:
        l.print_line

main_2()