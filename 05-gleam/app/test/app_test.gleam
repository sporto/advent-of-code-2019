import app
import gleam/should
import gleam/result
import gleam/list

pub fn mode_for_test() {
	app.mode_for(1002, 1)
	|> should.equal(app.Position)

	app.mode_for(1002, 2)
	|> should.equal(app.Value)

	app.mode_for(1002, 3)
	|> should.equal(app.Position)

	app.mode_for(99, 1)
	|> should.equal(app.Position)

	app.mode_for(199, 1)
	|> should.equal(app.Value)

	app.mode_for(199, 2)
	|> should.equal(app.Position)

	app.mode_for(1199, 2)
	|> should.equal(app.Value)

	app.mode_for(1199, 3)
	|> should.equal(app.Position)

	app.mode_for(11199, 3)
	|> should.equal(app.Value)
}

pub fn num_to_op_code_test() {
	// Multiply 3 is always Value
	app.num_to_op_code(1002)
	|> should.equal(app.Multiply(app.Position, app.Value, app.Value))
}

pub fn main_2_test() {
	let input = [1101,100,-1,4,0]

	app.main(input, 0).mem
		|> should.equal([1101,100,-1,4,99])
}



pub fn main_05_1_test() {
	let input = [3,225,1,225,6,6,1100,1,238,225,104,0,1102,79,14,225,1101,17,42,225,2,74,69,224,1001,224,-5733,224,4,224,1002,223,8,223,101,4,224,224,1,223,224,223,1002,191,83,224,1001,224,-2407,224,4,224,102,8,223,223,101,2,224,224,1,223,224,223,1101,18,64,225,1102,63,22,225,1101,31,91,225,1001,65,26,224,101,-44,224,224,4,224,102,8,223,223,101,3,224,224,1,224,223,223,101,78,13,224,101,-157,224,224,4,224,1002,223,8,223,1001,224,3,224,1,224,223,223,102,87,187,224,101,-4698,224,224,4,224,102,8,223,223,1001,224,4,224,1,223,224,223,1102,79,85,224,101,-6715,224,224,4,224,1002,223,8,223,1001,224,2,224,1,224,223,223,1101,43,46,224,101,-89,224,224,4,224,1002,223,8,223,101,1,224,224,1,223,224,223,1101,54,12,225,1102,29,54,225,1,17,217,224,101,-37,224,224,4,224,102,8,223,223,1001,224,3,224,1,223,224,223,1102,20,53,225,4,223,99,0,0,0,677,0,0,0,0,0,0,0,0,0,0,0,1105,0,99999,1105,227,247,1105,1,99999,1005,227,99999,1005,0,256,1105,1,99999,1106,227,99999,1106,0,265,1105,1,99999,1006,0,99999,1006,227,274,1105,1,99999,1105,1,280,1105,1,99999,1,225,225,225,1101,294,0,0,105,1,0,1105,1,99999,1106,0,300,1105,1,99999,1,225,225,225,1101,314,0,0,106,0,0,1105,1,99999,107,226,226,224,1002,223,2,223,1006,224,329,101,1,223,223,1108,677,226,224,1002,223,2,223,1006,224,344,101,1,223,223,7,677,226,224,102,2,223,223,1006,224,359,101,1,223,223,108,226,226,224,1002,223,2,223,1005,224,374,101,1,223,223,8,226,677,224,1002,223,2,223,1006,224,389,101,1,223,223,1108,226,226,224,102,2,223,223,1006,224,404,101,1,223,223,1007,677,677,224,1002,223,2,223,1006,224,419,101,1,223,223,8,677,677,224,1002,223,2,223,1005,224,434,1001,223,1,223,1008,226,226,224,102,2,223,223,1005,224,449,1001,223,1,223,1008,226,677,224,102,2,223,223,1006,224,464,101,1,223,223,1107,677,677,224,102,2,223,223,1006,224,479,101,1,223,223,107,677,677,224,1002,223,2,223,1005,224,494,1001,223,1,223,1107,226,677,224,1002,223,2,223,1005,224,509,101,1,223,223,1108,226,677,224,102,2,223,223,1006,224,524,101,1,223,223,7,226,226,224,1002,223,2,223,1005,224,539,101,1,223,223,108,677,677,224,1002,223,2,223,1005,224,554,101,1,223,223,8,677,226,224,1002,223,2,223,1005,224,569,1001,223,1,223,1008,677,677,224,102,2,223,223,1006,224,584,101,1,223,223,107,226,677,224,102,2,223,223,1005,224,599,1001,223,1,223,7,226,677,224,102,2,223,223,1005,224,614,101,1,223,223,1007,226,226,224,1002,223,2,223,1005,224,629,101,1,223,223,1107,677,226,224,1002,223,2,223,1006,224,644,101,1,223,223,108,226,677,224,102,2,223,223,1006,224,659,101,1,223,223,1007,677,226,224,102,2,223,223,1006,224,674,101,1,223,223,4,223,99,226]

	app.main(input, 1).outputs
	|> list.reverse
	|> list.head
	|> result.unwrap(-1)
	|> should.equal(9025675)
}

pub fn main_05_2_a_test() {
	let input = [3,9,8,9,10,9,4,9,99,-1,8]

	app.main(input, 8).outputs
	|> should.equal([1])

	app.main(input, 6).outputs
	|> should.equal([0])

	app.main(input, 7).outputs
	|> should.equal([0])
}

pub fn main_05_2_b_test() {
	let input = [3,9,7,9,10,9,4,9,99,-1,8]

	app.main(input, 7).outputs
	|> should.equal([1])

	app.main(input, 8).outputs
	|> should.equal([0])
}

pub fn main_05_2_c_test() {
	let input = [3,3,1108,-1,8,3,4,3,99]

	app.main(input, 8).outputs
	|> should.equal([1])

	app.main(input, 7).outputs
	|> should.equal([0])

	app.main(input, 9).outputs
	|> should.equal([0])
}

pub fn main_05_2_d_test() {
	let input = [3,3,1107,-1,8,3,4,3,99]

	app.main(input, 7).outputs
	|> should.equal([1])

	app.main(input, 8).outputs
	|> should.equal([0])
}

pub fn main_05_2_e_test() {
	let input = [3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9]

	app.main(input, 0).outputs
	|> should.equal([0])

	app.main(input, 2).outputs
	|> should.equal([1])
}

pub fn main_05_2_f_test() {
	let input = [3,3,1105,-1,9,1101,0,0,12,4,12,99,1]

	app.main(input, 0).outputs
	|> should.equal([0])

	app.main(input, 2).outputs
	|> should.equal([1])
}

pub fn main_05_2_g_test() {
	let input = [3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,
1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,
999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99]

	app.main(input, 7).outputs
	|> should.equal([999])

	app.main(input, 8).outputs
	|> should.equal([1000])

	app.main(input, 9).outputs
	|> should.equal([1001])
}

pub fn main_05_2_main_test() {
	let input = [3,225,1,225,6,6,1100,1,238,225,104,0,1102,79,14,225,1101,17,42,225,2,74,69,224,1001,224,-5733,224,4,224,1002,223,8,223,101,4,224,224,1,223,224,223,1002,191,83,224,1001,224,-2407,224,4,224,102,8,223,223,101,2,224,224,1,223,224,223,1101,18,64,225,1102,63,22,225,1101,31,91,225,1001,65,26,224,101,-44,224,224,4,224,102,8,223,223,101,3,224,224,1,224,223,223,101,78,13,224,101,-157,224,224,4,224,1002,223,8,223,1001,224,3,224,1,224,223,223,102,87,187,224,101,-4698,224,224,4,224,102,8,223,223,1001,224,4,224,1,223,224,223,1102,79,85,224,101,-6715,224,224,4,224,1002,223,8,223,1001,224,2,224,1,224,223,223,1101,43,46,224,101,-89,224,224,4,224,1002,223,8,223,101,1,224,224,1,223,224,223,1101,54,12,225,1102,29,54,225,1,17,217,224,101,-37,224,224,4,224,102,8,223,223,1001,224,3,224,1,223,224,223,1102,20,53,225,4,223,99,0,0,0,677,0,0,0,0,0,0,0,0,0,0,0,1105,0,99999,1105,227,247,1105,1,99999,1005,227,99999,1005,0,256,1105,1,99999,1106,227,99999,1106,0,265,1105,1,99999,1006,0,99999,1006,227,274,1105,1,99999,1105,1,280,1105,1,99999,1,225,225,225,1101,294,0,0,105,1,0,1105,1,99999,1106,0,300,1105,1,99999,1,225,225,225,1101,314,0,0,106,0,0,1105,1,99999,107,226,226,224,1002,223,2,223,1006,224,329,101,1,223,223,1108,677,226,224,1002,223,2,223,1006,224,344,101,1,223,223,7,677,226,224,102,2,223,223,1006,224,359,101,1,223,223,108,226,226,224,1002,223,2,223,1005,224,374,101,1,223,223,8,226,677,224,1002,223,2,223,1006,224,389,101,1,223,223,1108,226,226,224,102,2,223,223,1006,224,404,101,1,223,223,1007,677,677,224,1002,223,2,223,1006,224,419,101,1,223,223,8,677,677,224,1002,223,2,223,1005,224,434,1001,223,1,223,1008,226,226,224,102,2,223,223,1005,224,449,1001,223,1,223,1008,226,677,224,102,2,223,223,1006,224,464,101,1,223,223,1107,677,677,224,102,2,223,223,1006,224,479,101,1,223,223,107,677,677,224,1002,223,2,223,1005,224,494,1001,223,1,223,1107,226,677,224,1002,223,2,223,1005,224,509,101,1,223,223,1108,226,677,224,102,2,223,223,1006,224,524,101,1,223,223,7,226,226,224,1002,223,2,223,1005,224,539,101,1,223,223,108,677,677,224,1002,223,2,223,1005,224,554,101,1,223,223,8,677,226,224,1002,223,2,223,1005,224,569,1001,223,1,223,1008,677,677,224,102,2,223,223,1006,224,584,101,1,223,223,107,226,677,224,102,2,223,223,1005,224,599,1001,223,1,223,7,226,677,224,102,2,223,223,1005,224,614,101,1,223,223,1007,226,226,224,1002,223,2,223,1005,224,629,101,1,223,223,1107,677,226,224,1002,223,2,223,1006,224,644,101,1,223,223,108,226,677,224,102,2,223,223,1006,224,659,101,1,223,223,1007,677,226,224,102,2,223,223,1006,224,674,101,1,223,223,4,223,99,226]

	app.main(input, 5).outputs
	|> should.equal([11981754])
}