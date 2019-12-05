(* open Core *)
(* open Core.String *)

let file_name =
	"input.txt"

let read_file () : string list =
	Core.In_channel.read_lines file_name

type move =
	| R of int
	| L of int
	| U of int
	| D of int
	| MoveUnknown

let parse_move (input: string) : move =
	let code    = Core.String.prefix input 1 in
	let num_str = Core.String.drop_prefix input 1 in
	let num     = int_of_string num_str in
	match code with
	| "R" -> R num
	| "L" -> L num
	| "U" -> U num
	| "D" -> D num
	| _ -> MoveUnknown

let rec repeat e acc times =
	match times with
	| 0 -> acc
	| _ -> repeat e (e :: acc) (times - 1)

type step =
	| StepR
	| StepL
	| StepU
	| StepD

let move_to_steps (move: move) : step list =
	match move with
	| R steps -> repeat StepR [] steps
	| L steps -> repeat StepL [] steps
	| U steps -> repeat StepU [] steps
	| D steps -> repeat StepD [] steps
	| MoveUnknown -> []

let parse_path (input: string) : move list =
	input
		|> Core.String.split ~on:','
		|> Core.List.map ~f:parse_move

let rec walk_steps acc pos (steps: step list) : (int * int) list =
	match steps with
	| [] -> acc
	| step :: rest ->
		let nextAcc = pos :: acc
		in
		let (x, y) = pos
		in
		match step with
		| StepR -> walk_steps nextAcc (x + 1, y) rest
		| StepL -> walk_steps nextAcc (x - 1, y) rest
		| StepU -> walk_steps nextAcc (x, y + 1) rest
		| StepD -> walk_steps nextAcc (x, y - 1) rest

type pos_with_steps =
	{
		pos : ( int * int );
		steps : int;
	}

let walk_path (path: move list) : (int * int) list =
	path
		|> Core.List.concat_map ~f:move_to_steps
		|> walk_steps [] (0,0)


type pos_with_both_steps =
	{
		pos : ( int * int );
		steps1 : int;
		steps2 : int;
	}

type pos_with_both_steps_and_distance =
	{
		pos : ( int * int );
		total_steps : int;
		distance : int;
	}

let add_steps trail: pos_with_steps list =
	Core.List.mapi
		trail
		~f:(fun ix pos -> { pos = pos; steps = ix })

let coor_to_string (x, y) =
	"(" ^ string_of_int x ^ "," ^ string_of_int y ^ ")"
(* 
let trail_to_string trail =
	trail
		|> List.map ~f:coor_to_string
		|> String.concat ~sep:"," *)

let rec keep_dups
	(acc : pos_with_both_steps list)
	(prev : pos_with_steps)
	(list : pos_with_steps list)
	: pos_with_both_steps list =
	match list with
	| [] -> acc
	| x :: rest ->
		if prev.pos = x.pos then
			keep_dups 
				({ pos = prev.pos ; steps1 = prev.steps ; steps2 = x.steps } :: acc) 
				x
				rest
		else
			keep_dups acc x rest

let combine_steps ({ pos = (x, y); steps1 ; steps2 } : pos_with_both_steps)  =
	{
		pos = (x, y);
		total_steps = steps1 + steps2;
		distance = abs x + abs y;
	}

let print_pos_with_steps { pos = (x, y); steps } =
	Core.printf " { (%d, %d) ; steps %d }" x y steps

let print_pos_with_both_steps { pos = (x, y); steps1 ; steps2 } =
	Core.printf " { (%d, %d) ; steps1 %d ; steps2 %d }" x y steps1 steps2

let print_pos { pos = (x, y); total_steps; distance } =
	Core.printf " { (%d, %d) ; total_steps %d ; dist %d }" x y total_steps distance

let compare_using_pos (a: pos_with_steps) (b: pos_with_steps) =
	compare a.pos b.pos

let compare_using_distance a b =
	compare a.distance b.distance

let compare_using_total_steps a b =
	compare a.total_steps b.total_steps

let () =
	read_file ()
		|> Core.List.map ~f:parse_path
		|> Core.List.map ~f:walk_path
		|> Core.List.map ~f:add_steps
		|> Core.List.concat
		|> List.sort compare_using_pos
		|> keep_dups [] { pos = (0,0); steps = 0 }
		|> Core.List.map ~f:combine_steps
		|> List.sort compare_using_total_steps
		|> Core.List.iter ~f:print_pos
		(* |> Core.List.iter ~f:print_pos_with_both_steps *)