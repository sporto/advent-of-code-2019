import strutils, sequtils, tables, sugar

from "./vm" import consume

const FILENAME = "input.txt"

proc read_file(): seq[int] =
    let file = readFile(FILENAME)
    file.split(",").map(parseInt)

proc seq_to_mem(s: seq[int]): Table[int, int] =
    var pairs = newSeq[(int, int)]()

    for ix, val in s:
        pairs.add((ix, val))

    pairs.toTable

let example1 =
    # @[109,19,204,-34]
    @[109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99]

var example1mem =
    example1.seq_to_mem

var output =
    newSeq[int]()

echo consume(example1mem, 0, 0, @[], output)