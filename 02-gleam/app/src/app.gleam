import gleam/list
import gleam/result
import gleam/io

pub fn hello_world() {
	"Hello, from app!"
}

type OpCode {
	Add
	Multiply
	Halt
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

fn consume(mem: List(Int), pointer: Int) -> List(Int) {
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
							consume(next_mem, params.next_pointer)
						})
						|> result.unwrap(mem)
				}
				Multiply -> {
					// io.println("Multiply")
					let params = params3(mem, pointer)

					case params {
						Ok(params) ->
							{
								let next_mem = put(mem, params.p3, params.p1 * params.p2)
								consume(next_mem, params.next_pointer)
							}
						_ ->
							mem
					}
				}
				Halt -> {
					// io.println("Halt")
					mem
				}
			}
		_ ->
			mem
	}
}

pub fn main(input: List(Int)) {
	consume(input, 0)
}
