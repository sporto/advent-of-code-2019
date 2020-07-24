import gleam/list
import gleam/result
import gleam/io

pub fn hello_world() {
	"Hello, from app!"
}

type OpCode {
	Add
	Multiply
	Store
	Halt
	Output
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
	case num {
		1 -> Add
		2 -> Multiply
		3 -> Store
		4 -> Output
		_ -> Halt
	}
}

fn get_op_code(mem: List(Int), pointer: Int) -> Result(OpCode, Nil) {
	list.at(mem, pointer)
		|> result.map(_, num_to_op_code)
}

fn get_value(mem, pointer, address_offset)  -> Result(Int, Nil) {
	list.at(mem, pointer + address_offset)
}

// Get the position at the index, then get the value for the position
fn get_position_then_value(mem, pointer, address_offset) -> Result(Int, Nil) {
	get_value(mem, pointer, address_offset)
		|> result.then(_, fn(address) { list.at(mem, address) })
}

fn put(mem, address, val) {
	let left = list.take(mem, address)
	let right = list.drop(mem, address + 1)

	list.flatten([left, [val], right])
}

fn params3(mem, pointer) {
	try p1 = get_position_then_value(mem, pointer, 1)
	try p2 = get_position_then_value(mem, pointer, 2)
	try p3 = get_value(mem, pointer, 3)

	Ok(Triple(p1, p2, p3, pointer + 4))
}

fn consume(mem: List(Int), input input: Int, output output: Int, pointer pointer: Int) -> tuple(List(Int), Int) {
	// io.debug(mem)
	// io.debug(pointer)

	case get_op_code(mem, pointer) {
		Ok(op_code) ->
			case op_code {
				Add -> {
					// io.println("Add")
					params3(mem, pointer)
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
				Multiply -> {
					// io.println("Multiply")
					let params = params3(mem, pointer)

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
				Store -> {
					let address = get_value(mem, pointer, 1)

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
				Output -> {
					get_position_then_value(mem, pointer, 1)
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