import strutils, sequtils, unicode, sugar

const FILENAME = "example1.txt"

proc parseLine(l: string): seq[bool] =
    l.toRunes.map(toUTF8).map(c =>
        c == "#"
    )

proc get_file_input(): seq[seq[bool]] =
    readFile(FILENAME)
        .splitLines
        .map(parseLine)

echo get_file_input()