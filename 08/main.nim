import unicode, strutils, sequtils

const WIDE = 25
const TALL = 6

const FILENAME = "input.txt"

proc read_file(): seq[int] =
    let file = readFile(FILENAME)
    file
        .toRunes
        .map(toUTF8)
        .map(parseInt)

echo read_file()