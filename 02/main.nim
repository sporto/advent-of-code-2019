import strutils, sequtils

proc read_file(): seq[int] =
    let filename = "input.txt"
    let file = readFile(filename)
    file.split(",").map(parseInt)

proc consume(memory: var seq[int], instruction_pointer: int): seq[int] =
    let op_code = memory[instruction_pointer]
    case op_code:
        of 1:
            let address_1 = memory[instruction_pointer + 1]
            let address_2 = memory[instruction_pointer + 2]
            let address_3 = memory[instruction_pointer + 3]
            memory[address_3] = memory[address_1] + memory[address_2]
            memory.consume(instruction_pointer + 4)
        of 2:
            let address_1 = memory[instruction_pointer + 1]
            let address_2 = memory[instruction_pointer + 2]
            let address_3 = memory[instruction_pointer + 3]
            memory[address_3] = memory[address_1] * memory[address_2]
            memory.consume(instruction_pointer + 4)
        of 99:
            memory
        else:
            raise

proc main(): int =
    for noun in countup(0, 99):
        for verb in countup(0, 99):
            var memory = read_file()
            memory[1] = noun
            memory[2] = verb
            let result = memory.consume(0)
            if result[0] == 19690720:
                return 100 * noun + verb

echo main()
