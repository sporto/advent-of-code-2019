import gleam/list

pub external fn inspect(a) -> a = "Elixir.IO" "inspect"

pub struct Pos {
  x: Int
  y: Int
  z: Int
}

pub struct Moon {
	position: Pos
	velocity: Pos
}

// Update the velocity
fn apply_gravity(moon: Moon) -> Moon {
	moon
}

// update the position
fn apply_velocity(moon: Moon) {
	let Moon(velocity, position) = moon
	let Pos(x: px, y: py, z: pz) = position
	let Pos(x: vx, y: vy, z: vz) = velocity
	Moon(
		velocity: velocity,
		position: Pos(
			x: px + vx,
			y: py + vy,
			z: pz + vz,
		)
	)
}

fn apply_gravities(moons: List(Moon)) -> List(Moon) {
	moons
		|> list.map(_, apply_gravity)
}

fn apply_velocities(moons) {
	moons
		|> list.map(_, apply_velocity)
}

fn tick(time: Int, moons: List(Moon)) {
	let in_range = time < 10
	case in_range {
		True -> {
			let new_moons = moons
				|> apply_gravities(_)
				|> apply_velocities(_)
			inspect(new_moons)
			tick(time + 1, new_moons)
		}
		False ->
			moons
	}
}

fn new_velocity() {
	Pos(
		x: 0,
		y: 0,
		z: 0,
	)
}

fn new_moon(x,y,z) -> Moon {
	Moon(
		position: Pos(
		  x: x, y: y, z: z
	  	),
		velocity: new_velocity()
	  )
}

pub fn main() {
  let moons = [
	  new_moon(-1, 0, 2),
	  new_moon(2, -10, -7),
	  new_moon(4, -8, 8),
	  new_moon(3, 5, -1),
  ]
  tick(0, moons)
}
