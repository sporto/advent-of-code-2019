import strutils, sequtils, tables, sugar

from "./vm" import consume

const FILENAME = "input.txt"

proc get_file_input(): seq[int] =
    readFile(FILENAME).split(",").map(parseInt)

proc seq_to_mem(s: seq[int64]): Table[int64, int64] =
    var pairs = newSeq[(int64, int64)]()

    for ix, val in s:
        pairs.add((cast[int64](ix), val))

    pairs.toTable

let example1 =
    @[109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99]

var mem1 =
    example1.map(v => cast[int64](v)).seq_to_mem

let example2 =
    @[1102,34915192,34915192,7,4,7,99,0]

var mem2 =
    example2.map(v => cast[int64](v)).seq_to_mem

let example3: seq[int64] =
    @[cast[int64](104),1125899906842624,99]

var mem3 =
    example3.seq_to_mem

var mem =
    get_file_input()
        .map(v => cast[int64](v))
        .seq_to_mem

var output =
    newSeq[int64]()

proc main(): void =
    # echo mem
    let input = @[cast[int64](1)]
    # let input = newSeq[int64]()
    echo consume(mem, 0, 0, input, output)

main()
