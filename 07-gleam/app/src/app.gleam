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
		mem: Mem,
		pointer: Int,
	)
}

pub type Stage {
	Output(
		program: Program,
		outputs: List(Int)
	)
	Halted(
		program: Program
	)
	Failure(
		program: Program
	)
}

pub fn program_mem(program: Program) -> Mem {
	program.mem
}

fn program_pointer(program: Program) -> Int {
	program.pointer
}

pub type Return{
	Return(
		program: Program,
		outputs: List(Int),
	)
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

pub type ConsumeReturn{
	ConsumeReturn(
		stage: Stage,
		next_inputs: List(Int),
	)
}

fn consume(program: Program, inputs: List(Int)) -> ConsumeReturn {
	// io.debug(mem)
	// io.debug(pointer)
	let error = ConsumeReturn(
		stage: Failure(program),
		next_inputs: inputs,
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
								mem : next_mem,
								pointer: params.next_pointer,
							)
							consume(next_program, inputs)
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
									mem : next_mem,
									pointer: params.next_pointer,
								)
								consume(next_program, inputs)
							}
						_ ->
							error
					}
				}
				Store(m1) -> {
					params1(program, m1)
						|> result.map(fn(one: One) {
							let input = inputs
								|> list.head
								|> result.unwrap(0)

							let next_inputs = inputs |> list.drop(1)

							let next_mem = put(program_mem(program), one.val1, input)

							let next_program = Program(
								mem : next_mem,
								pointer: one.next_pointer,
							)
							consume(next_program, next_inputs)
						})
						|> result.unwrap(error)
				}
				Out(m1) -> {
					params1(program, m1)
						|> result.map(fn(one: One) {
							// io.debug(one.val1)
							let next_program = Program(
								mem : program_mem(program),
								pointer: one.next_pointer,
							)

							ConsumeReturn(
								Output(
									program : next_program,
									outputs: [one.val1],
								),
								inputs
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
								mem : program_mem(program),
								pointer: next_pointer,
							)
							consume(next_program, inputs)
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
								mem : program_mem(program),
								pointer: next_pointer,
							)
							consume(next_program, inputs)
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
								mem : next_mem,
								pointer: three.next_pointer,
							)
							consume(next_program, inputs)
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
								mem : next_mem,
								pointer: three.next_pointer,
							)
							consume(next_program, inputs)
						})
						|> result.unwrap(error)
				}
				Halt -> {
					// io.println("Halt")
					ConsumeReturn(Halted(program), inputs)
				}
			}
		_ ->
			error
	}
}

fn consume_until_halted(stage: Stage, inputs: List(Int), outputs: List(Int)) -> Return {
	case stage {
		Halted(program) -> Return(program, outputs)
		Failure(program) -> Return(program, outputs)
		Output(program, new_outputs) -> {
			// io.debug("Output")
			// io.debug(output)
			let ConsumeReturn(next_stage, next_inputs) = consume(program, inputs)
			let next_outputs = list.append(outputs, new_outputs)
			// io.debug(next_outputs)
			consume_until_halted(next_stage, next_inputs, next_outputs)
		}
	}
}


pub fn main(mem: List(Int), input: Int) -> Return {
	let program = Program(
		mem: mem,
		pointer: 0,
	)
	let stage = Output(program, [])
	consume_until_halted(stage, [input], [])
}

fn sum(a:Int, b:Int) { a + b }

fn list_max(lst) {
	list.fold(over: lst, from: 0, with: int.max)
}

pub fn sequence(mem: List(Int), phase_seq: List(Int)) -> Int {
	let accumulate = fn(phase: Int, input: Int) {
		let program = Program(
			mem: mem,
			pointer: 0,
		)
		let stage = Output(program, [])
		let return = consume_until_halted(stage ,[phase, input], [])

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

// fn feedback_loop__process_next_in_queue(queue_: queue.Queue(Stage), inputs: List(Int)) -> List(Int) {
// 	case queue.pop_front(queue_) {
// 		Error(_) ->
// 			[]
// 		Ok(pair) -> {
// 			let tuple(amplifier_stage, amplifier_stages) = pair
// 			let run_amplifier = fn(program: Program) -> List(Int) {
// 				// Run amplifier using previous output as input
// 				// On Output, store output and run next amplifier
// 				// Put this amplifier at the end of the queue
// 				let next_program = Program(
// 					mem: program_mem(program),
// 					pointer: program_pointer(program),
// 				)
// 				let ConsumeReturn(next_stage, next_inputs) = consume(next_program, inputs)
// 				case next_stage {
// 					Output(_, outputs) ->
// 						feedback_loop__process_next_in_queue(
// 							queue.push_back(
// 								amplifier_stages, next_stage
// 							),
// 							outputs
// 						)
// 					_ ->
// 						feedback_loop__process_next_in_queue(
// 							queue.push_back(
// 								amplifier_stages, next_stage
// 							),
// 							next_inputs
// 						)
// 				}
// 			}

// 			case amplifier_stage {
// 				Output(program, _) ->
// 					run_amplifier(program)
// 				// If the amplifier is already halted, then stop
// 				Halted(program) -> inputs
// 				Failure(program) -> inputs
// 			}
// 		}
// 	}
// }

// pub fn feedback_loop(mem: Mem, phase_seq: List(Int)) -> List(Int) {
// 	let make_amplifier = fn(phase) {
// 		Program(
// 			mem: mem,
// 			pointer: 0,
// 			inputs: [phase],
// 		)
// 	}

// 	let q = list.map(phase_seq, make_amplifier)
// 		|> list.map(fn(program) { Output(program, []) })
// 		|> queue.from_list

// 	feedback_loop__process_next_in_queue(q, [])
// }