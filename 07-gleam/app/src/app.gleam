import gleam/list
import gleam/result
import gleam/io
import gleam/string
import gleam/int
import gleam/queue

pub type OpCode {
	Add(ParameterMode, ParameterMode, ParameterMode)
	Multiply(ParameterMode, ParameterMode, ParameterMode)
	Store(ParameterMode)
	JumpIfTrue(ParameterMode, ParameterMode)
	JumpIfFalse(ParameterMode, ParameterMode)
	LessThan(ParameterMode, ParameterMode, ParameterMode)
	Equal(ParameterMode, ParameterMode, ParameterMode)
	Halt
	Out(ParameterMode)
}

pub type ParameterMode {
	Position
	Value
}

type Mem = List(Int)

pub type Program {
	Program(
		code: String,
		mem: Mem,
		pointer: Int,
		inputs: List(Int),
		outputs: List(Int),
		state: State,
	)
}

pub type State {
	Running
	Output(Int)
	Halted
	Failure
}

pub fn program_mem(program: Program) -> Mem {
	program.mem
}

fn program_pointer(program: Program) -> Int {
	program.pointer
}

type One {
	One(
		val1: Int,
		next_pointer: Int,
	)
}

type Two {
	Two(
		val1: Int,
		val2: Int,
		next_pointer: Int,
	)
}

type Three {
	Three(
		val1: Int,
		val2: Int,
		val3: Int,
		next_pointer: Int,
	)
}

pub fn mode_for(num: Int, position: Int) -> ParameterMode {
	let n = num
		|> int.to_string
		|> string.drop_right(position + 1)

	case string.ends_with(n, "1") {
		True ->
			Value
		False ->
			Position
	}
}

pub fn num_to_op_code(num: Int) {
	let m1 = mode_for(num,1)
	let m2 = mode_for(num,2)
	let m3 = mode_for(num,3)
	case num % 100 {
		1 -> Add(m1, m2, Value)
		2 -> Multiply(m1, m2, Value)
		3 -> Store(Value)
		4 -> Out(m1)
		5 -> JumpIfTrue(m1, m2)
		6 -> JumpIfFalse(m1, m2)
		7 -> LessThan(m1, m2, Value)
		8 -> Equal(m1, m2, Value)
		_ -> Halt
	}
}

fn get_op_code(program: Program) -> Result(OpCode, Nil) {
	list.at(program_mem(program), program_pointer(program))
		|> result.map(_, num_to_op_code)
}

fn get_value(program: Program, offset address_offset: Int, mode mode: ParameterMode)  -> Result(Int, Nil) {
	let first = list.at(
		program_mem(program), program_pointer(program) + address_offset
	)

	case mode {
		Value ->
			first
		Position ->
			first
			|> result.then(_, fn(address) { 
				list.at(program_mem(program), address) 
			})
	}
}

fn put(mem, address, val) {
	let left = list.take(mem, address)
	let right = list.drop(mem, address + 1)

	list.flatten([left, [val], right])
}

fn params1(program: Program, m1) {
	try p1 = get_value(program, 1, mode: m1)

	Ok(One(p1, program_pointer(program) + 2))
}

fn params2(program: Program, m1, m2) {
	try p1 = get_value(program, 1, mode: m1)
	try p2 = get_value(program, 2, mode: m2)

	Ok(Two(p1, p2, program_pointer(program) + 3))
}

fn params3(program: Program, m1, m2, m3) {
	try p1 = get_value(program, 1, mode: m1)
	try p2 = get_value(program, 2, mode: m2)
	try p3 = get_value(program, 3, mode: m3)

	Ok(Three(p1, p2, p3, program_pointer(program) + 4))
}

fn consume(program: Program) -> Program {
	// io.debug(mem)
	// io.debug(pointer)
	let error = Program(
		code: program.code,
		mem: program.mem,
		pointer: program.pointer,
		inputs: program.inputs,
		outputs: program.outputs,
		state: Failure,
	)

	case get_op_code(program) {
		Ok(op_code) ->
			case op_code {
				Add(m1, m2, m3) -> {
					// io.println("Add")
					// io.debug(m1)
					// io.debug(m2)
					// io.debug(m3)
					params3(program, m1, m2, m3)
						|> result.map(fn(params: Three) {
							// io.debug(params.val3)
							let next_mem = put(
								program_mem(program), params.val3, params.val1 + params.val2
							)

							let next_program = Program(
								code: program.code,
								mem : next_mem,
								pointer: params.next_pointer,
								inputs: program.inputs,
								outputs: program.outputs,
								state: Running,
							)
							consume(next_program)
						})
						|> result.unwrap(error)
				}
				Multiply(m1, m2, m3) -> {
					// io.println("Multiply")
					let params = params3(program, m1, m2, m3)

					case params {
						Ok(params) ->
							{
								let next_mem = put(
									program_mem(program), params.val3, params.val1 * params.val2
								)

								let next_program = Program(
									code: program.code,
									mem : next_mem,
									pointer: params.next_pointer,
									inputs: program.inputs,
									outputs: program.outputs,
									state: Running,
								)
								consume(next_program)
							}
						_ ->
							error
					}
				}
				Store(m1) -> {
					params1(program, m1)
						|> result.map(fn(one: One) {
							let input = program.inputs
								|> list.head
								|> result.unwrap(0)

							let next_inputs = program.inputs |> list.drop(1)

							let next_mem = put(program_mem(program), one.val1, input)

							let next_program = Program(
								code: program.code,
								mem : next_mem,
								pointer: one.next_pointer,
								inputs: next_inputs,
								outputs: program.outputs,
								state: Running,
							)
							consume(next_program)
						})
						|> result.unwrap(error)
				}
				Out(m1) -> {
					params1(program, m1)
						|> result.map(fn(one: One) {
							// io.debug(one.val1)
							Program(
								code: program.code,
								mem : program_mem(program),
								pointer: one.next_pointer,
								inputs: program.inputs,
								outputs: list.append(program.outputs, [one.val1]),
								state: Output(one.val1),
							)
						})
						|> result.unwrap(error)
				}
				JumpIfTrue(m1, m2) -> {
					params2(program, m1, m2)
						|> result.map(fn(two: Two) {
							let next_pointer = case two.val1 {
								0 -> two.next_pointer
								_ -> two.val2
							}

							let next_program = Program(
								code: program.code,
								mem : program_mem(program),
								pointer: next_pointer,
								inputs: program.inputs,
								outputs: program.outputs,
								state: Running,
							)
							consume(next_program)
						})
						|> result.unwrap(error)
				}
				JumpIfFalse(m1, m2) -> {
					params2(program, m1, m2)
						|> result.map(fn(two: Two) {
							let next_pointer = case two.val1 {
								0 -> two.val2
								_ -> two.next_pointer
							}

							let next_program = Program(
								code: program.code,
								mem : program_mem(program),
								pointer: next_pointer,
								inputs: program.inputs,
								outputs: program.outputs,
								state: Running,
							)
							consume(next_program)
						})
						|> result.unwrap(error)
				}
				LessThan(m1, m2, m3) -> {
					params3(program, m1, m2, m3)
						|> result.map(fn(three: Three) {
							let value = case three.val1 < three.val2 {
								True -> 1
								False -> 0
							}
							let next_mem = put(
								program_mem(program), three.val3, value
							)
							let next_program = Program(
								code: program.code,
								mem : next_mem,
								pointer: three.next_pointer,
								inputs: program.inputs,
								outputs: program.outputs,
								state: Running,
							)
							consume(next_program)
						})
						|> result.unwrap(error)
				}
				Equal(m1, m2, m3) -> {
					params3(program, m1, m2, m3)
						|> result.map(fn(three: Three) {
							let value = case three.val1 == three.val2 {
								True -> 1
								False -> 0
							}
							let next_mem = put(program_mem(program), three.val3, value)

							let next_program = Program(
								code: program.code,
								mem : next_mem,
								pointer: three.next_pointer,
								inputs: program.inputs,
								outputs: program.outputs,
								state: Running,
							)
							consume(next_program)
						})
						|> result.unwrap(error)
				}
				Halt -> {
					// io.println("Halt")
					Program(
						code: program.code,
						mem : program.mem,
						pointer: program.pointer,
						inputs: program.inputs,
						outputs: program.outputs,
						state: Halted,
					)
				}
			}
		_ ->
			error
	}
}

fn consume_until_halted(program: Program) -> Program {
	case program.state {
		Halted -> program
		Failure -> program
		_ -> {
			// io.debug("Output")
			// io.debug(output)
			let next_program = consume(program)
			// io.debug(next_outputs)
			consume_until_halted(next_program)
		}
	}
}


pub fn main(mem: List(Int), input: Int) -> Program {
	let program = Program(
		code: "",
		mem: mem,
		pointer: 0,
		inputs: [input],
		outputs: [],
		state: Running,
	)
	consume_until_halted(program)
}

fn sum(a:Int, b:Int) { a + b }

fn list_max(lst) {
	list.fold(over: lst, from: 0, with: int.max)
}

pub fn sequence(mem: List(Int), phase_seq: List(Int)) -> Int {
	let accumulate = fn(phase: Int, input: Int) {
		let program = Program(
			code: "",
			mem: mem,
			pointer: 0,
			inputs: [phase, input],
			outputs: [],
			state: Running,
		)
		let return = consume_until_halted(program)

		// Add the outputs
		list.fold(over: return.outputs, from: 0, with: sum)
	}

	list.fold(over: phase_seq, from: 0, with: accumulate)
}

// interleave 1 [2;3] = [ [1;2;3]; [2;1;3]; [2;3;1] ] 
pub fn interleave(x, lst) -> List(List(Int)) {
	case lst {
		[] ->
			[[x]]
		[head, ..tail] -> {
			let rest = list.map(interleave(x, tail), fn(y) { [head, ..y] } )

			[[x, ..lst] , ..rest]
		}
	}
}

// permutations [1; 2; 3] = [[1; 2; 3]; [2; 1; 3]; [2; 3; 1]; [1; 3; 2]; [3; 1; 2]; [3; 2; 1]]
pub fn permutations(lst: List(Int)) -> List(List(Int)) {
	case lst {
		[head, ..tail] ->
			list.flatten(
				list.map(permutations(tail), fn(x) { interleave(head, x) })
			)
		_ -> [lst]
	}
}

pub fn combinations(n: Int) -> List(List(Int)) {
	list.range(0, n)
		|> permutations
}

pub fn day7(mem: List(Int)) -> Int {
	combinations(5)
		|> list.map(fn(lst) {
			sequence(mem, lst)
		})
		|> list_max
}

fn print_queue_order(queue_) {
	// io.debug(queue_)
	queue_
		|> queue.to_list
		|> list.map(fn(p: Program) { p.code })
		|> list.reverse
		|> io.debug
}

fn feedback_loop__process_next_in_queue(
		queue_: queue.Queue(Program),
		previous_outputs: List(Int)
	) -> List(Int) {

	// print_queue_order(queue_)

	case queue.pop_front(queue_) {
		Error(_) ->
			[]
		Ok(pair) -> {
			let tuple(amplifier_program, rest_amplifier_programs) = pair

			// io.println(amplifier_program.code)
			// io.debug(amplifier_program.state)

			// io.debug(amplifier_program.inputs)

			case amplifier_program.state {
				// If the amplifier is already halted, then stop
				Halted -> amplifier_program.inputs
				Failure -> amplifier_program.inputs
				_ -> {
					let next_inputs = list.append(amplifier_program.inputs, previous_outputs)

					// io.println("next_inputs")
					// io.debug(next_inputs)

					let amplifier = Program(
						code: amplifier_program.code,
						mem: amplifier_program.mem,
						pointer: amplifier_program.pointer,
						inputs: next_inputs,
						outputs: amplifier_program.outputs,
						state: amplifier_program.state,
					)

					// io.println(amplifier.code)

					let consumed_amplifier_program = consume(amplifier)

					// io.println(consumed_amplifier_program.code)

					let outputs = consumed_amplifier_program.outputs

					// io.debug(outputs)

					let next_amplifier_program = Program(
						code: consumed_amplifier_program.code,
						mem: consumed_amplifier_program.mem,
						pointer: consumed_amplifier_program.pointer,
						inputs: consumed_amplifier_program.inputs,
						outputs: [],
						state: consumed_amplifier_program.state,
					)

					// io.println(next_amplifier_program.code)

					let next_queue = queue.push_front(
						rest_amplifier_programs,
						next_amplifier_program
					)

					// print_queue_order(next_queue)

					// io.debug(rest_amplifier_programs)
					// io.debug(next_queue)

					feedback_loop__process_next_in_queue(next_queue, outputs)
				}
			}
		}
	}
}

fn code_for_index(index: Int) -> String {
	case index {
		0 -> "A"
		1 -> "B"
		2 -> "C"
		3 -> "D"
		4 -> "E"
		_ -> "X"
	}
}

pub fn feedback_loop(mem: Mem, phase_seq: List(Int)) -> List(Int) {
	let make_amplifier = fn(index, phase) {
		let code = code_for_index(index)
		// io.println(code)
		Program(
			code: code,
			mem: mem,
			pointer: 0,
			inputs: [phase],
			outputs: [],
			state: Running,
		)
	}

	io.println("phase_seq")
	io.debug(phase_seq)

	let queue = list.index_map(phase_seq, make_amplifier)
		|> queue.from_list

	// print_queue_order(queue)

	feedback_loop__process_next_in_queue(queue, [])
}