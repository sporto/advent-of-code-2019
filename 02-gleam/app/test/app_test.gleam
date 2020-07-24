import app
import gleam/should

pub fn hello_world_test() {
  app.hello_world()
  |> should.equal("Hello, from app!")
}

pub fn main_test() {
	let input = [1,9,10,3,2,3,11,0,99,30,40,50]

	app.main(input)
	|> should.equal([3500,9,10,70,2,3,11,0,99,30,40,50])
}