import gleam/list
import gleam/result
import gleam/io
import gleam/string
import gleam/int

pub fn hello_world() {
	"Hello, from app!"
}

pub type OpCode {
	Add(ParameterMode, ParameterMode, ParameterMode)
	Multiply(ParameterMode, ParameterMode, ParameterMode)
	Store(ParameterMode)
	Halt
	Output(ParameterMode)
}

pub type ParameterMode {
	Position
	Value
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
		1 -> Add(m1, m2, m3)
		2 -> Multiply(m1, m2, m3)
		3 -> Store(m1)
		4 -> Output(m1)
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

fn params1(mem, pointer, m1) {
	try p1 = get_value(mem, pointer, 1, mode: m1)

	Ok(One(p1, pointer + 2))
}

fn params2(mem, pointer, m1, m2) {
	try p1 = get_value(mem, pointer, 1, mode: m1)
	try p2 = get_value(mem, pointer, 2, mode: m2)

	Ok(Two(p1, p2, pointer + 3))
}

fn params3(mem, pointer, m1, m2, m3) {
	try p1 = get_value(mem, pointer, 1, mode: m1)
	try p2 = get_value(mem, pointer, 2, mode: m2)
	try p3 = get_value(mem, pointer, 3, mode: m3)

	Ok(Three(p1, p2, p3, pointer + 4))
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
						|> result.map(fn(params: Three) {
							let next_mem = put(mem, params.val3, params.val1 + params.val2)
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
								let next_mem = put(mem, params.val3, params.val1 * params.val2)
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
					params1(mem, pointer, m1)
						|> result.map(fn(one: One) {
							let next_mem = put(mem, one.val1, input)
							consume(
								next_mem,
								input: input,
								output: output,
								pointer: one.next_pointer
							)
						})
						|> result.unwrap(tuple(mem, input))
				}
				Output(m1) -> {
					params1(mem, pointer, m1)
						|> result.map(fn(one: One) {
							consume(
								mem,
								input: input,
								output: one.val1,
								pointer: one.next_pointer
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