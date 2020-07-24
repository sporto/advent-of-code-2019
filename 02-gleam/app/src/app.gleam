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

fn get_value(mem, pointer, offset)  -> Result(Int, Nil) {
	list.at(mem, pointer + offset)
}

// Get the position at the index, then get the value for the position
fn get_position_then_value(mem, pointer, offset) -> Result(Int, Nil) {
	get_value(mem, pointer, offset)
		|> result.then(_, fn(address) { list.at(mem, address) })
}

fn put(mem, address, val) {
	let left = list.take(mem, address)
	let right = list.drop(mem, address + 1)

	list.flatten([left, [val], right])
}

fn params3(mem, pointer) {
	let p1_res = get_position_then_value(mem, pointer, 1)
	let p2_res = get_position_then_value(mem, pointer, 2)
	let p3_res = get_value(mem, pointer, 3)
	case p1_res {
		Ok(p1) ->
			case p2_res {
				Ok(p2) ->
					case p3_res {
						Ok(p3) ->
							Ok(Triple(p1, p2, p3))
						_ ->
							Error(Nil)
					}
				_ ->
					Error(Nil)
			}
		_ ->
			Error(Nil)
	}
}

fn consume(mem: List(Int), pointer: Int) -> List(Int) {
	io.debug(mem)
	io.debug(pointer)
	case get_op_code(mem, pointer) {
		Ok(op_code) ->
			case op_code {
				Add -> {
					io.println("Add")
					let params = params3(mem, pointer)

					case params {
						Ok(params) ->
							{
								let Triple(p1, p2, p3) = params
								io.debug(params)
								let next_mem = put(mem, p3, p1 + p2)
								consume(next_mem, pointer + 4)
							}
						_ ->
							mem
					}
				}
				Multiply -> {
					io.println("Multiply")
					let params = params3(mem, pointer)

					case params {
						Ok(params) ->
							{
								let Triple(p1, p2, p3) = params
								let next_mem = put(mem, p3, p1 * p2)
								consume(next_mem, pointer + 4)
							}
						_ ->
							mem
					}
				}
				Halt -> {
					io.println("Halt")
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
