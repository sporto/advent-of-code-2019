import strutils, sequtils

proc read_file(): seq[int] =
    let filename = "input.txt"
    let file = readFile(filename)
    file.split(",").map(parseInt)

proc consume(instructions: var seq[int], pos: int): seq[int] =
    let op = instructions[pos]
    case op:
        of 1:
            let p1 = instructions[pos + 1]
            let p2 = instructions[pos + 2]
            let p3 = instructions[pos + 3]
            instructions[p3] = instructions[p1] + instructions[p2]
            instructions.consume(pos + 4)
        of 2:
            let p1 = instructions[pos + 1]
            let p2 = instructions[pos + 2]
            let p3 = instructions[pos + 3]
            instructions[p3] = instructions[p1] * instructions[p2]
            instructions.consume(pos + 4)
        of 99:
            instructions
        else:
            raise

proc main(): int =
    var instructions = read_file()
    instructions[1] = 12
    instructions[2] = 2
    let result = instructions.consume(0)
    instructions[0]

echo main()
