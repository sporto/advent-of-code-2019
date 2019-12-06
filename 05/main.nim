import strutils, sequtils, math

proc read_file(): seq[int] =
    let filename = "input.txt"
    let file = readFile(filename)
    file.split(",").map(parseInt)

proc get_op_code(op: int): int =
    op mod 100

proc get_mode(op: int, pos: int): float =
    (floor (op.toFloat / pow(10, pos.toFloat + 1))) mod 10

proc get_input(memory: seq[int], instruction_pointer: int, op: int,
        pos: int): int =
    let mode = get_mode(op, pos)
    let address_or_value = memory[instruction_pointer + pos]
    if mode == 0:
        memory[address_or_value]
    else:
        address_or_value

proc consume(memory: var seq[int], instruction_pointer: int): seq[int] =
    let op = memory[instruction_pointer]
    # echo op

    case op.get_op_code:
        of 1:
            let in1 = get_input(memory, instruction_pointer, op, 1)
            let in2 = get_input(memory, instruction_pointer, op, 2)
            let address_3 = memory[instruction_pointer + 3]
            memory[address_3] = in1 + in2
            memory.consume(instruction_pointer + 4)
        of 2:
            let in1 = get_input(memory, instruction_pointer, op, 1)
            let in2 = get_input(memory, instruction_pointer, op, 2)
            let address_3 = memory[instruction_pointer + 3]
            memory[address_3] = in1 * in2
            memory.consume(instruction_pointer + 4)
        of 3:
            let address = memory[instruction_pointer + 1]
            memory[address] = 1
            memory.consume(instruction_pointer + 2)
        of 4:
            let address = memory[instruction_pointer + 1]
            echo memory[address]
            memory.consume(instruction_pointer + 2)
        of 99:
            memory
        else:
            raise newException(IOError, "failed")

proc main(): int =
    var memory = read_file()
    let _ = memory.consume(0)
    memory[0]

echo main()

# 9025675
