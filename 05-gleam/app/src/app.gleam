import gleam/list
import gleam/result
import gleam/io

pub fn hello_world() {
	"Hello, from app!"
}

type OpCode {
	Add(ParameterMode, ParameterMode, ParameterMode)
	Multiply(ParameterMode, ParameterMode, ParameterMode)
	Store(ParameterMode)
	Halt
	Output(ParameterMode)
}

type ParameterMode {
	Position
	Value
}

type Triple {
	Triple(
		p1: Int,
		p2: Int,
		p3: Int,
		next_pointer: Int,
	)
}

fn num_to_op_code(num: Int) {
	case num % 100 {
		1 -> Add(Position, Position, Value)
		2 -> Multiply(Position, Position, Value)
		3 -> Store(Position)
		4 -> Output(Position)
		_ -> Halt
	}
}

fn get_op_code(mem: List(Int), pointer: Int) -> Result(OpCode, Nil) {
	list.at(mem, pointer)
		|> result.map(_, num_to_op_code)
}

fn get_value(mem, pointer pointer: Int, offset address_offset: Int, mode mode: ParameterMode)  -> Result(Int, Nil) {
	let first = list.at(mem, pointer + address_offset)

	case mode {
		Value ->
			first
		Position ->
			first
			|> result.then(_, fn(address) { list.at(mem, address) })
	}
}

fn put(mem, address, val) {
	let left = list.take(mem, address)
	let right = list.drop(mem, address + 1)

	list.flatten([left, [val], right])
}

fn params3(mem, pointer, m1, m2, m3) {
	try p1 = get_value(mem, pointer, 1, mode: m1)
	try p2 = get_value(mem, pointer, 2, mode: m2)
	try p3 = get_value(mem, pointer, 3, mode: m3)

	Ok(Triple(p1, p2, p3, pointer + 4))
}

fn consume(mem: List(Int), input input: Int, output output: Int, pointer pointer: Int) -> tuple(List(Int), Int) {
	// io.debug(mem)
	// io.debug(pointer)

	case get_op_code(mem, pointer) {
		Ok(op_code) ->
			case op_code {
				Add(m1, m2, m3) -> {
					// io.println("Add")
					params3(mem, pointer, m1, m2, m3)
						|> result.map(fn(params: Triple) {
							let next_mem = put(mem, params.p3, params.p1 + params.p2)
							consume(
								next_mem,
								input: input,
								output: output,
								pointer: params.next_pointer
							)
						})
						|> result.unwrap(tuple(mem, input))
				}
				Multiply(m1, m2, m3) -> {
					// io.println("Multiply")
					let params = params3(mem, pointer, m1, m2, m3)

					case params {
						Ok(params) ->
							{
								let next_mem = put(mem, params.p3, params.p1 * params.p2)
								consume(
									next_mem,
									input: input,
									output: output,
									pointer: params.next_pointer
								)
							}
						_ ->
							tuple(mem,input)
					}
				}
				Store(m1) -> {
					let address = get_value(
						mem,
						pointer: pointer,
						offset: 1,
						mode: m1,
					)

					address
					|> result.map(fn(address: Int) {
						let next_mem = put(mem, address, input)
						consume(
							next_mem,
							input: input,
							output: output,
							pointer: pointer + 2
						)
					})
					|> result.unwrap(tuple(mem, input))
				}
				Output(m1) -> {
					get_value(mem, pointer, 1, mode: m1)
					|> result.map(fn(value:Int) {
						io.debug(value)
						consume(
							mem,
							input: input,
							output: value,
							pointer: pointer + 2
						)
					})
					|> result.unwrap(tuple(mem, input))
				}
				Halt -> {
					// io.println("Halt")
					tuple(mem, output)
				}
			}
		_ ->
			tuple(mem, input)
	}
}

pub fn main(mem: List(Int)) -> List(Int) {
	let tuple(a, _) = consume(mem, input: 0, output: 0, pointer: 0)
	a
}


pub fn main_with_input(mem: List(Int), input: Int) -> Int {
	let tuple(_, out) = consume(mem, input: input, output: 0, pointer: 0)
	out
}