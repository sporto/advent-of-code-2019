import app
import gleam/should
import gleam/result
import gleam/list

pub fn hello_world_test() {
  app.hello_world()
  |> should.equal("Hello, from app!")
}

pub fn main_test() {
	let input = [1,9,10,3,2,3,11,0,99,30,40,50]

	app.main(input)
	|> should.equal([3500,9,10,70,2,3,11,0,99,30,40,50])

	app.main([1,0,0,0,99])
	|> should.equal([2,0,0,0,99])

	app.main([2,3,0,3,99])
	|> should.equal([2,3,0,6,99])

	app.main([2,4,4,5,99,0])
	|> should.equal([2,4,4,5,99,9801])
}

pub fn main_2_test() {
	let input = [1,12,2,3,1,1,2,3,1,3,4,3,1,5,0,3,2,10,1,19,1,19,5,23,1,23,9,27,2,27,6,31,1,31,6,35,2,35,9,39,1,6,39,43,2,10,43,47,1,47,9,51,1,51,6,55,1,55,6,59,2,59,10,63,1,6,63,67,2,6,67,71,1,71,5,75,2,13,75,79,1,10,79,83,1,5,83,87,2,87,10,91,1,5,91,95,2,95,6,99,1,99,6,103,2,103,6,107,2,107,9,111,1,111,5,115,1,115,6,119,2,6,119,123,1,5,123,127,1,127,13,131,1,2,131,135,1,135,10,0,99,2,14,0,0]

	app.main(input)
		|> list.head
		|> result.unwrap(-1)
		|> should.equal(4945026)
}