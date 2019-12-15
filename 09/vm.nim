import strutils, sequtils, math, strformat, sugar, tables

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
    AdjustRelativeBase,
    Halt

proc get_op_code(op: int): OpCode =
    let code = op mod 100
    case code:
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
        of 9:
            AdjustRelativeBase
        of 99:
            Halt
        else:
            echo code
            raise newException(IOError, "failed")

proc read(mem: Table[int, int], add: int): int =
    if mem.has_key(add):
        mem[add]
    else:
        0

proc write(mem: var Table[int, int], add: int, value: int): void =
    mem[add] = value

proc get_mode(op: int, pos: int): Mode =
    let mode = (floor (op.toFloat / pow(10, pos.toFloat + 1))) mod 10
    if mode == 0:
        Position
    else:
        Immediate

proc get_param(
        mem: Table[int, int],
        pointer: int,
        op: int,
        pos: int
    ): int =

    let mode = get_mode(op, pos)
    let address_or_value = mem.read(pointer + pos)

    case mode
        of Position:
            mem.read(address_or_value)
        of Immediate:
            address_or_value

# proc set(mem: var seq[int], add: int, val: int): void =
#     mem.read(add, va)

proc consume*(
        mem: var Table[int, int],
        pointer: int,
        relative_base: int,
        inputs: seq[int],
        output: int
    ): int =

    let op = mem.read(pointer)
    echo mem
    echo "pointer ", pointer
    echo "op ", op
    # echo pointer
    # echo op.get_op_code

    case op.get_op_code:
        of Add:
            let val1 = get_param(mem, pointer, op, 1)
            let val2 = get_param(mem, pointer, op, 2)
            let address_3 = mem.read(pointer + 3)
            # echo address_3
            mem.write(address_3, val1 + val2)
            # echo fmt"  *opMul* val1: {val1}, val2: {val2}, par3: {address_3}"
            # echo mem
            mem.consume(
                pointer + 4,
                relative_base,
                inputs,
                output
            )
        of Mul:
            let val1 = get_param(mem, pointer, op, 1)
            let val2 = get_param(mem, pointer, op, 2)
            let address_3 = mem.read(pointer + 3)
            mem.write(address_3, val1 * val2)
            # echo fmt"  *opMul* val1: {val1}, val2: {val2}, par3: {address_3}"
            # echo mem
            mem.consume(
                pointer + 4,
                relative_base,
                inputs,
                output
            )
        of Input:
            let address = mem.read(pointer + 1)
            # echo " - input into address " & $(address)
            if inputs.len == 0:
                raise newException(IOError, "No more inputs")
            else:
                let input = inputs[0]
                # echo " - Input " & $(input)
                mem.write(address, input)
                mem.consume(
                    pointer + 2,
                    relative_base,
                    inputs[1 .. inputs.len - 1],
                    output
                )
        of Output:
            let in1 = get_param(mem, pointer, op, 1)
            # echo mem.read(pointer + 1)
            # echo " - out " & $(in1)
            # echo mem.read(31)
            # echo mem
            mem.consume(
                pointer + 2,
                relative_base,
                inputs,
                in1
            )
        of JumpIfTrue:
            let in1 = get_param(mem, pointer, op, 1)
            let in2 = get_param(mem, pointer, op, 2)
            let next_pointer =
                if in1 == 0:
                    pointer + 3
                else:
                    in2
                    # echo " - jumping to " & $(in2)
            mem.consume(
                next_pointer,
                relative_base,
                inputs,
                output
            )
        of JumpIfFalse:
            let in1 = get_param(mem, pointer, op, 1)
            let in2 = get_param(mem, pointer, op, 2)
            let next_pointer =
                if in1 == 0:
                    # echo " - jumping to " & $(in2)
                    in2
                else:
                    pointer + 3
            mem.consume(
                next_pointer,
                relative_base,
                inputs,
                output
            )
        of LessThan:
            let val1 = get_param(mem, pointer, op, 1)
            let val2 = get_param(mem, pointer, op, 2)
            let par3 = mem.read(pointer + 3) # get_param(mem, pointer, op, 3)
            if val1 < val2:
                # echo " - set " & $(par3) & " to 1"
                mem.write(par3, 1)
            else:
                # echo " - set " & $(par3) & " to 0"
                mem.write(par3, 0)
            # echo mem
            # echo fmt"  *opLessThan* val1: {val1}, val2: {val2}, par3: {par3}"
            mem.consume(
                pointer + 4,
                relative_base,
                inputs,
                output
            )
        of Equals:
            let in1 = get_param(mem, pointer, op, 1)
            let in2 = get_param(mem, pointer, op, 2)
            let in3 = mem.read(pointer + 3)
             # get_param(mem, pointer, op, 3)
                                          # echo " - p1 " & $(in1)
                                          # echo " - p2 " & $(in2)
            if in1 == in2:
                # echo " - set " & $(in3) & " to 1"
                mem.write(in3, 1)
            else:
                # echo " - set " & $(in3) & " to 0"
                mem.write(in3, 0)
            mem.consume(
                pointer + 4,
                relative_base,
                inputs,
                output
            )
        of AdjustRelativeBase:
            let in1 = get_param(mem, pointer, op, 1)
            mem.consume(
                pointer + 1,
                relative_base + in1,
                inputs,
                output
            )
        of Halt:
            output

