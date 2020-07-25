import gleam/list
import gleam/result
import gleam/io
import gleam/string
import gleam/int

pub type OpCode {
	Add(ParameterMode, ParameterMode, ParameterMode)
	Multiply(ParameterMode, ParameterMode, ParameterMode)
	Store(ParameterMode)
	JumpIfTrue(ParameterMode, ParameterMode)
	JumpIfFalse(ParameterMode, ParameterMode)
	LessThan(ParameterMode, ParameterMode, ParameterMode)
	Equal(ParameterMode, ParameterMode, ParameterMode)
	Halt
	Output(ParameterMode)
}

pub type ParameterMode {
	Position
	Value
}

pub type State {
	State(
		mem: List(Int),
		pointer: Int,
		inputs: List(Int),
		outputs : List(Int),
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
		4 -> Output(m1)
		5 -> JumpIfTrue(m1, m2)
		6 -> JumpIfFalse(m1, m2)
		7 -> LessThan(m1, m2, Value)
		8 -> Equal(m1, m2, Value)
		_ -> Halt
	}
}

fn get_op_code(state: State) -> Result(OpCode, Nil) {
	list.at(state.mem, state.pointer)
		|> result.map(_, num_to_op_code)
}

fn get_value(state: State, offset address_offset: Int, mode mode: ParameterMode)  -> Result(Int, Nil) {
	let first = list.at(state.mem, state.pointer + address_offset)

	case mode {
		Value ->
			first
		Position ->
			first
			|> result.then(_, fn(address) { list.at(state.mem, address) })
	}
}

fn put(mem, address, val) {
	let left = list.take(mem, address)
	let right = list.drop(mem, address + 1)

	list.flatten([left, [val], right])
}

fn params1(state: State, m1) {
	try p1 = get_value(state, 1, mode: m1)

	Ok(One(p1, state.pointer + 2))
}

fn params2(state: State, m1, m2) {
	try p1 = get_value(state, 1, mode: m1)
	try p2 = get_value(state, 2, mode: m2)

	Ok(Two(p1, p2, state.pointer + 3))
}

fn params3(state: State, m1, m2, m3) {
	try p1 = get_value(state, 1, mode: m1)
	try p2 = get_value(state, 2, mode: m2)
	try p3 = get_value(state, 3, mode: m3)

	Ok(Three(p1, p2, p3, state.pointer + 4))
}

fn consume(state: State) -> State {
	// io.debug(mem)
	// io.debug(pointer)

	case get_op_code(state) {
		Ok(op_code) ->
			case op_code {
				Add(m1, m2, m3) -> {
					io.println("Add")
					// io.debug(m1)
					// io.debug(m2)
					// io.debug(m3)
					params3(state, m1, m2, m3)
						|> result.map(fn(params: Three) {
							// io.debug(params.val3)
							let next_mem = put(state.mem, params.val3, params.val1 + params.val2)
							let next_state = State(
								mem : next_mem,
								pointer: params.next_pointer,
								inputs: state.inputs,
								outputs: state.outputs,
							)
							consume(next_state)
						})
						|> result.unwrap(state)
				}
				Multiply(m1, m2, m3) -> {
					// io.println("Multiply")
					let params = params3(state, m1, m2, m3)

					case params {
						Ok(params) ->
							{
								let next_mem = put(state.mem, params.val3, params.val1 * params.val2)
								let next_state = State(
									mem : next_mem,
									pointer: params.next_pointer,
									inputs: state.inputs,
									outputs: state.outputs,
								)
								consume(next_state)
							}
						_ ->
							state
					}
				}
				Store(m1) -> {
					params1(state, m1)
						|> result.map(fn(one: One) {
							let input = state.inputs
								|> list.head
								|> result.unwrap(0)
							let next_mem = put(state.mem, one.val1, input)
							let next_state = State(
								mem : next_mem,
								pointer: one.next_pointer,
								inputs: state.inputs |> list.drop(1),
								outputs: state.outputs,
							)
							consume(next_state)
						})
						|> result.unwrap(state)
				}
				Output(m1) -> {
					params1(state, m1)
						|> result.map(fn(one: One) {
							// io.debug(one.val1)
							let next_outputs = list.append(state.outputs, [one.val1])
							let next_state = State(
								mem : state.mem,
								pointer: one.next_pointer,
								inputs: state.inputs,
								outputs: next_outputs,
							)
							consume(next_state)
						})
						|> result.unwrap(state)
				}
				JumpIfTrue(m1, m2) -> {
					params2(state, m1, m2)
						|> result.map(fn(two: Two) {
							let next_pointer = case two.val1 {
								0 -> two.next_pointer
								_ -> two.val2
							}

							let next_state = State(
								mem : state.mem,
								pointer: next_pointer,
								inputs: state.inputs,
								outputs: state.outputs,
							)
							consume(next_state)
						})
						|> result.unwrap(state)
				}
				JumpIfFalse(m1, m2) -> {
					params2(state, m1, m2)
						|> result.map(fn(two: Two) {
							let next_pointer = case two.val1 {
								0 -> two.val2
								_ -> two.next_pointer
							}

							let next_state = State(
								mem : state.mem,
								pointer: next_pointer,
								inputs: state.inputs,
								outputs: state.outputs,
							)
							consume(next_state)
						})
						|> result.unwrap(state)
				}
				LessThan(m1, m2, m3) -> {
					params3(state, m1, m2, m3)
						|> result.map(fn(three: Three) {
							let value = case three.val1 < three.val2 {
								True -> 1
								False -> 0
							}
							let next_mem = put(state.mem, three.val3, value)
							let next_state = State(
								mem : next_mem,
								pointer: three.next_pointer,
								inputs: state.inputs,
								outputs: state.outputs,
							)
							consume(next_state)
						})
						|> result.unwrap(state)
				}
				Equal(m1, m2, m3) -> {
					params3(state, m1, m2, m3)
						|> result.map(fn(three: Three) {
							let value = case three.val1 == three.val2 {
								True -> 1
								False -> 0
							}
							let next_mem = put(state.mem, three.val3, value)
							let next_state = State(
								mem : next_mem,
								pointer: three.next_pointer,
								inputs: state.inputs,
								outputs: state.outputs,
							)
							consume(next_state)
						})
						|> result.unwrap(state)
				}
				Halt -> {
					// io.println("Halt")
					state
				}
			}
		_ ->
			state
	}
}

pub fn main(mem: List(Int), input: Int) -> State {
	let state = State(
		mem: mem,
		pointer: 0,
		inputs: [input],
		outputs: [],
	)
	let result = consume(state)
	io.debug(result.outputs)
	result
}

fn sum(a:Int, b:Int) { a + b }

pub fn sequence(mem: List(Int), phase_seq: List(Int)) -> Int {
	let accumulate = fn(phase: Int, input: Int) {
		let state = State(
			mem: mem,
			pointer: 0,
			inputs: [phase, input],
			outputs: [],
		)
		let result = consume(state)

		list.fold(over: result.outputs, from: 0, with: sum)
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
//   match lst with
//   | hd::tl -> List.concat (List.map (interleave hd) (permutations tl))
//   | _ -> [lst]

// pub fn combinations(n: Int) -> List(List(Int)) {
// 	list.range(0, n)
// 		|> permutations
// }