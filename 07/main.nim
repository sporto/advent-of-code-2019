import strutils, sequtils, math, strformat

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

const FILENAME = "input.1.txt"

proc read_file(): seq[int] =
    let file = readFile(FILENAME)
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

proc get_param(memory: seq[int], pointer: int, op: int,
        pos: int): int =
    let mode = get_mode(op, pos)
    let address_or_value = memory[pointer + pos]

    case mode
        of Position:
            memory[address_or_value]
        of Immediate:
            address_or_value

proc consume(memory: var seq[int],
        pointer: int,
        inputs: seq[int],
        output: int
    ): int =

    let op = memory[pointer]
    # echo pointer
    echo op.get_op_code

    case op.get_op_code:
        of Add:
            let val1 = get_param(memory, pointer, op, 1)
            let val2 = get_param(memory, pointer, op, 2)
            let address_3 = memory[pointer + 3]
            memory[address_3] = val1 + val2
            # echo fmt"  *opMul* val1: {val1}, val2: {val2}, par3: {address_3}"
            # echo memory
            memory.consume(pointer + 4, inputs, output)
        of Mul:
            let val1 = get_param(memory, pointer, op, 1)
            let val2 = get_param(memory, pointer, op, 2)
            let address_3 = memory[pointer + 3]
            memory[address_3] = val1 * val2
            # echo fmt"  *opMul* val1: {val1}, val2: {val2}, par3: {address_3}"
            # echo memory
            memory.consume(pointer + 4, inputs, output)
        of Input:
            let address = memory[pointer + 1]
            # echo " - input into address " & $(address)
            if inputs.len == 0:
                raise newException(IOError, "No more inputs")
            else:
                let input = inputs[0]
                echo " - Input " & $(input)
                memory[address] = input
                memory.consume(pointer + 2, inputs[1 ..
                        < inputs.len], output)
        of Output:
            let in1 = get_param(memory, pointer, op, 1)
            echo memory[pointer + 1]
            echo " - out " & $(in1)
            # echo memory[31]
            # echo memory
            memory.consume(pointer + 2, inputs, in1)
        of JumpIfTrue:
            let in1 = get_param(memory, pointer, op, 1)
            let in2 = get_param(memory, pointer, op, 2)
            if in1 == 0:
                memory.consume(pointer + 3, inputs, output)
            else:
                echo " - jumping to " & $(in2)
                memory.consume(in2, inputs, output)
        of JumpIfFalse:
            let in1 = get_param(memory, pointer, op, 1)
            let in2 = get_param(memory, pointer, op, 2)
            if in1 == 0:
                echo " - jumping to " & $(in2)
                memory.consume(in2, inputs, output)
            else:
                memory.consume(pointer + 3, inputs, output)
        of LessThan:
            let val1 = get_param(memory, pointer, op, 1)
            let val2 = get_param(memory, pointer, op, 2)
            let par3 = memory[pointer + 3] # get_param(memory, pointer, op, 3)
            if val1 < val2:
                # echo " - set " & $(par3) & " to 1"
                memory[par3] = 1
            else:
                # echo " - set " & $(par3) & " to 0"
                memory[par3] = 0
            # echo memory
            echo fmt"  *opLessThan* val1: {val1}, val2: {val2}, par3: {par3}"
            memory.consume(pointer + 4, inputs, output)
        of Equals:
            let in1 = get_param(memory, pointer, op, 1)
            let in2 = get_param(memory, pointer, op, 2)
            let in3 = memory[pointer + 3] # get_param(memory, pointer, op, 3)
                                          # echo " - p1 " & $(in1)
                                          # echo " - p2 " & $(in2)
            if in1 == in2:
                # echo " - set " & $(in3) & " to 1"
                memory[in3] = 1
            else:
                # echo " - set " & $(in3) & " to 0"
                memory[in3] = 0
            memory.consume(pointer + 4, inputs, output)
        of Halt:
            output

proc run_amplifier(phase: int, signal: int): int =
    var memory = read_file()
    memory.consume(0, @[phase, signal], -1)

proc run_amplifiers(phases: seq[int], signal: int): int =
    if phases.len > 0:
        echo "Running phase " & $(phases[0])
        let new_signal = run_amplifier(phases[0], signal)
        echo "New signal is " & $(new_signal)
        run_amplifiers(phases[1 .. phases.len - 1], new_signal)
    else:
        signal

proc make_combinations(): seq[seq[int]] =
    for a in (0 .. 4):
        for b in (0 .. 4):
            if b == a:
                continue
            for c in (0 .. 4):
                if c == a or c == b:
                    continue
                for d in (0 .. 4):
                    if d == a or d == b or d == c:
                        continue
                    for e in (0 .. 4):
                        if e == a or e == b or e == c or e == d:
                            continue
                        result.add(@[a, b, c, d, e])

proc main(): void =
    let combinations = make_combinations()
    echo run_amplifiers(@[1, 0, 4, 3, 2], 0)
    # for comb in combinations:

main()

# 9025675
