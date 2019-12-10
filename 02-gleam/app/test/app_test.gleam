import app
import gleam/expect

pub fn hello_world_test() {
  app.hello_world()
  |> expect.equal(_, "Hello, from app!")
}
