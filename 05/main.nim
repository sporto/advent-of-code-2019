import strutils, sequtils, math

type Mode = enum Position, Immediate

type OpCode = enum
    Add,
    Mul,
    Input,
    Output,
    JumpIfTrue,
    JumpIfFalse,
    LessThan,
    Equals,
    Halt

const NUM_INPUT = 8

proc read_file(): seq[int] =
    let filename = "input.2.txt"
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
        of 5:
            JumpIfTrue
        of 6:
            JumpIfFalse
        of 7:
            LessThan
        of 8:
            Equals
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
    echo instruction_pointer
    echo op.get_op_code

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
            echo " - input into address " & $(address)
            memory[address] = NUM_INPUT
            memory.consume(instruction_pointer + 2)
        of Output:
            let in1 = get_input(memory, instruction_pointer, op, 1)
            echo " - out " & $(in1)
            memory.consume(instruction_pointer + 2)
        of JumpIfTrue:
            let in1 = get_input(memory, instruction_pointer, op, 1)
            let in2 = get_input(memory, instruction_pointer, op, 2)
            if in1 == 0:
                memory.consume(instruction_pointer + 3)
            else:
                echo " - jumping to " & $(in2)
                memory.consume(in2)
        of JumpIfFalse:
            let in1 = get_input(memory, instruction_pointer, op, 1)
            let in2 = get_input(memory, instruction_pointer, op, 2)
            if in1 == 0:
                echo " - jumping to " & $(in2)
                memory.consume(in2)
            else:
                memory.consume(instruction_pointer + 3)
        of LessThan:
            let in1 = get_input(memory, instruction_pointer, op, 1)
            let in2 = get_input(memory, instruction_pointer, op, 2)
            let in3 = get_input(memory, instruction_pointer, op, 3)
            if in1 < in2:
                echo " - set " & $(in3) & " to 1"
                memory[in3] = 1
            else:
                echo " - set " & $(in3) & " to 0"
                memory[in3] = 0
            memory.consume(instruction_pointer + 4)
        of Equals:
            let in1 = get_input(memory, instruction_pointer, op, 1)
            let in2 = get_input(memory, instruction_pointer, op, 2)
            let in3 = get_input(memory, instruction_pointer, op, 3)
            echo " - p1 " & $(in1)
            echo " - p2 " & $(in2)
            if in1 == in2:
                echo " - set " & $(in3) & " to 1"
                memory[in3] = 1
            else:
                echo " - set " & $(in3) & " to 0"
                memory[in3] = 0
            memory.consume(instruction_pointer + 4)
        of Halt:
            memory

proc main(): void =
    var memory = read_file()
    let _ = memory.consume(0)

main()

# 9025675
