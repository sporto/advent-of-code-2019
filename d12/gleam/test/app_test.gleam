import app
import gleam/expect

pub fn main_test() {
  app.main()
  |> expect.equal(_, [])
}
