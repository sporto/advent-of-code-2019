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

pub type State {
	State(
		mem: Mem,
		pointer: Int,
		inputs: List(Int),
	)
}

pub type Stage {
	Active(
		state: State
	)
	Output(
		state: State,
		output: Int
	)
	Halted(
		state: State
	)
	Error(
		state: State
	)
}

pub fn state_mem(state: State) -> Mem {
	state.mem
}

fn state_pointer(state: State) -> Int {
	state.pointer
}

fn state_inputs(state: State) -> List(Int) {
	state.inputs
}

pub type Return{
	Return(
		state: State,
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

fn get_op_code(state: State) -> Result(OpCode, Nil) {
	list.at(state_mem(state), state_pointer(state))
		|> result.map(_, num_to_op_code)
}

fn get_value(state: State, offset address_offset: Int, mode mode: ParameterMode)  -> Result(Int, Nil) {
	let first = list.at(
		state_mem(state), state_pointer(state) + address_offset)

	case mode {
		Value ->
			first
		Position ->
			first
			|> result.then(_, fn(address) { 
				list.at(state_mem(state), address) 
			})
	}
}

fn put(mem, address, val) {
	let left = list.take(mem, address)
	let right = list.drop(mem, address + 1)

	list.flatten([left, [val], right])
}

fn params1(state: State, m1) {
	try p1 = get_value(state, 1, mode: m1)

	Ok(One(p1, state_pointer(state) + 2))
}

fn params2(state: State, m1, m2) {
	try p1 = get_value(state, 1, mode: m1)
	try p2 = get_value(state, 2, mode: m2)

	Ok(Two(p1, p2, state_pointer(state) + 3))
}

fn params3(state: State, m1, m2, m3) {
	try p1 = get_value(state, 1, mode: m1)
	try p2 = get_value(state, 2, mode: m2)
	try p3 = get_value(state, 3, mode: m3)

	Ok(Three(p1, p2, p3, state_pointer(state) + 4))
}

fn consume(state: State) -> Stage {
	// io.debug(mem)
	// io.debug(pointer)
	let error = Error(state)

	case get_op_code(state) {
		Ok(op_code) ->
			case op_code {
				Add(m1, m2, m3) -> {
					// io.println("Add")
					// io.debug(m1)
					// io.debug(m2)
					// io.debug(m3)
					params3(state, m1, m2, m3)
						|> result.map(fn(params: Three) {
							// io.debug(params.val3)
							let next_mem = put(
								state_mem(state), params.val3, params.val1 + params.val2
							)

							let next_state = State(
								mem : next_mem,
								pointer: params.next_pointer,
								inputs: state_inputs(state),
							)
							consume(next_state)
						})
						|> result.unwrap(error)
				}
				Multiply(m1, m2, m3) -> {
					// io.println("Multiply")
					let params = params3(state, m1, m2, m3)

					case params {
						Ok(params) ->
							{
								let next_mem = put(
									state_mem(state), params.val3, params.val1 * params.val2
								)

								let next_state = State(
									mem : next_mem,
									pointer: params.next_pointer,
									inputs: state_inputs(state),
								)
								consume(next_state)
							}
						_ ->
							error
					}
				}
				Store(m1) -> {
					params1(state, m1)
						|> result.map(fn(one: One) {
							let input = state_inputs(state)
								|> list.head
								|> result.unwrap(0)

							let next_mem = put(state_mem(state), one.val1, input)

							let next_inputs = state_inputs(state) |> list.drop(1)

							let next_state = State(
								mem : next_mem,
								pointer: one.next_pointer,
								inputs: next_inputs,
							)
							consume(next_state)
						})
						|> result.unwrap(error)
				}
				Out(m1) -> {
					params1(state, m1)
						|> result.map(fn(one: One) {
							// io.debug(one.val1)
							let next_state = State(
								mem : state_mem(state),
								pointer: one.next_pointer,
								inputs: state_inputs(state),
							)

							Output(
								state : next_state,
								output: one.val1,
							)
						})
						|> result.unwrap(error)
				}
				JumpIfTrue(m1, m2) -> {
					params2(state, m1, m2)
						|> result.map(fn(two: Two) {
							let next_pointer = case two.val1 {
								0 -> two.next_pointer
								_ -> two.val2
							}

							let next_state = State(
								mem : state_mem(state),
								pointer: next_pointer,
								inputs: state_inputs(state),
							)
							consume(next_state)
						})
						|> result.unwrap(error)
				}
				JumpIfFalse(m1, m2) -> {
					params2(state, m1, m2)
						|> result.map(fn(two: Two) {
							let next_pointer = case two.val1 {
								0 -> two.val2
								_ -> two.next_pointer
							}

							let next_state = State(
								mem : state_mem(state),
								pointer: next_pointer,
								inputs: state_inputs(state),
							)
							consume(next_state)
						})
						|> result.unwrap(error)
				}
				LessThan(m1, m2, m3) -> {
					params3(state, m1, m2, m3)
						|> result.map(fn(three: Three) {
							let value = case three.val1 < three.val2 {
								True -> 1
								False -> 0
							}
							let next_mem = put(
								state_mem(state), three.val3, value
							)

							let next_state = State(
								mem : next_mem,
								pointer: three.next_pointer,
								inputs: state_inputs(state),
							)
							consume(next_state)
						})
						|> result.unwrap(error)
				}
				Equal(m1, m2, m3) -> {
					params3(state, m1, m2, m3)
						|> result.map(fn(three: Three) {
							let value = case three.val1 == three.val2 {
								True -> 1
								False -> 0
							}
							let next_mem = put(state_mem(state), three.val3, value)

							let next_state = State(
								mem : next_mem,
								pointer: three.next_pointer,
								inputs: state_inputs(state),
							)
							consume(next_state)
						})
						|> result.unwrap(error)
				}
				Halt -> {
					// io.println("Halt")
					Halted(state)
				}
			}
		_ ->
			error
	}
}

fn consume_until_halted(stage: Stage, outputs: List(Int)) -> Return {
	case stage {
		Active(state) -> {
			let next_stage = consume(state)
			consume_until_halted(next_stage, outputs)
		}
		Halted(state) -> Return(state, outputs)
		Error(state) -> Return(state, outputs)
		Output(state, output) -> {
			// io.debug("Output")
			// io.debug(output)
			let next_stage = consume(state)
			let next_outputs = list.append(outputs, [output])
			// io.debug(next_outputs)
			consume_until_halted(next_stage, next_outputs)
		}
	}
}


pub fn main(mem: List(Int), input: Int) -> Return {
	let state = State(
		mem: mem,
		pointer: 0,
		inputs: [input],
	)
	let stage = Active(state)
	consume_until_halted(stage, [])
}

fn sum(a:Int, b:Int) { a + b }

fn list_max(lst) {
	list.fold(over: lst, from: 0, with: int.max)
}

pub fn sequence(mem: List(Int), phase_seq: List(Int)) -> Int {
	let accumulate = fn(phase: Int, input: Int) {
		let state = State(
			mem: mem,
			pointer: 0,
			inputs: [phase, input],
		)
		let stage = Active(state)
		let return = consume_until_halted(stage ,[])

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

// pub fn feedback_loop(mem, phase_seq) {
// 	let make_amplifier = fn(phase) {
// 		State(
// 			mem: mem,
// 			pointer: 0,
// 			inputs: [phase],
// 		)
// 	}

// 	let q = list.map(phase_seq, make_amplifier)
// 		|> list.map(Start)
// 		|> queue.from_list

// 	let run(queue_) {
// 		let res = queue.pop_front(queue_)
// 		case res {
// 			Error(_) ->
// 				Error("Can get amplifier")
// 			Ok((amplifier_state, amplifiers)) -> {
// 				case amplifier_state {
// 					Active(state) ->
// 						let response = consume_until_output(amplifier)
// 					Output(state, output) ->

// 					Halted(_) ->
// 					Error(_)
// 				}

// 			}
// 		}
// 	}
// }