import strutils, sequtils, math

type Mode = enum Position, Immediate

type OpCode = enum
    Add,
    Mul,
    Input,
    Output,
    Halt

proc read_file(): seq[int] =
    let filename = "input.txt"
    let file = readFile(filename)
    file.split(",").map(parseInt)

proc get_op_code(op: int): OpCode =
    case op mod 100:
        of 1:
            Add
        of 2:
            Mul
        of 3:
            Input
        of 4:
            Output
        of 99:
            Halt
        else:
            raise newException(IOError, "failed")

proc get_mode(op: int, pos: int): Mode =
    let mode = (floor (op.toFloat / pow(10, pos.toFloat + 1))) mod 10
    if mode == 0:
        Position
    else:
        Immediate

proc get_input(memory: seq[int], instruction_pointer: int, op: int,
        pos: int): int =
    let mode = get_mode(op, pos)
    let address_or_value = memory[instruction_pointer + pos]

    case mode
        of Position:
            memory[address_or_value]
        of Immediate:
            address_or_value

proc consume(memory: var seq[int], instruction_pointer: int): seq[int] =
    let op = memory[instruction_pointer]
    # echo op

    case op.get_op_code:
        of Add:
            let in1 = get_input(memory, instruction_pointer, op, 1)
            let in2 = get_input(memory, instruction_pointer, op, 2)
            let address_3 = memory[instruction_pointer + 3]
            memory[address_3] = in1 + in2
            memory.consume(instruction_pointer + 4)
        of Mul:
            let in1 = get_input(memory, instruction_pointer, op, 1)
            let in2 = get_input(memory, instruction_pointer, op, 2)
            let address_3 = memory[instruction_pointer + 3]
            memory[address_3] = in1 * in2
            memory.consume(instruction_pointer + 4)
        of Input:
            let address = memory[instruction_pointer + 1]
            memory[address] = 1
            memory.consume(instruction_pointer + 2)
        of Output:
            let address = memory[instruction_pointer + 1]
            echo memory[address]
            memory.consume(instruction_pointer + 2)
        of Halt:
            memory

proc main(): int =
    var memory = read_file()
    let _ = memory.consume(0)
    memory[0]

echo main()

# 9025675
