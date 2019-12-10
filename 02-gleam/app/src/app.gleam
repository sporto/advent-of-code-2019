import gleam/list
import gleam/result

pub fn hello_world() {
	"Hello, from app!"
}

enum OpCode {
	Add
	Multiply
	Halt
}

struct Triple {
  p1: Int
  p2: Int
  p3: Int
}

fn program() {
	[1,9,10,3,2,3,11,0,99,30,40,50]
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

fn get_value(mem, pointer, pos) -> Result(Int, Nil) {
	list.at(mem, pointer + pos)
		|> result.then(_, fn(address) { list.at(mem, address) })
}

fn put(mem, address, val) {
	mem
}

fn param1(mem, pointer) -> Result(Int, Nil) {
	get_value(mem, pointer, 1)
}

fn param2(mem, pointer) -> Result(Int, Nil) {
	get_value(mem, pointer, 1)
}

fn param3(mem, pointer) -> Result(Int, Nil) {
	get_value(mem, pointer, 1)
}

fn params3(mem, pointer) {
	let p1_res = param1(mem, pointer)
	let p2_res = param2(mem, pointer)
	let p3_res = param3(mem, pointer)
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

fn add(mem, pointer) -> Int {
	let params_result = params3(mem, pointer)

	case params_result {
		Ok(params) ->
			{
				let Triple(p1, p2, p3) = params
				let next_mem = put(mem, p3, p1 + p2)
				consume(next_mem, pointer + 3)
			}
		_ ->
			-1
	}
}

fn consume(mem: List(Int), pointer: Int) -> Int {
	case get_op_code(mem, pointer) {
		Ok(op_code) ->
			case op_code {
				Add -> add(mem, pointer)
				Multiply ->
					2
				Halt ->
					3
			}
		_ ->
			-1
	}
}
