open Core
open Core.String

let file_name =
	"input.a.txt"

let read_file () : string list =
	In_channel.read_lines file_name

type move =
	| R of int
	| L of int
	| U of int
	| D of int
	| MoveUnknown

let move_to_num move =
	match move with
	| R n -> n
	| L n -> n
	| D n -> n
	| U n -> n
	| MoveUnknown -> 0

let parse_move (input: string) : move =
	let code    = prefix input 1 in
	let num_str = drop_prefix input 1 in
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
		|> String.split ~on:','
		|> List.map ~f:parse_move

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


let walk_path (path: move list) : (int * int) list =
	path
		|> List.concat_map ~f:move_to_steps
		|> walk_steps [] (0,0)

let coor_to_string (x, y) =
	"(" ^ string_of_int x ^ "," ^ string_of_int y ^ ")"

let trail_to_string trail =
	trail
		|> List.map ~f:coor_to_string
		|> String.concat ~sep:","

let () =
	read_file ()
		|> List.map ~f:parse_path
		|> List.map ~f:walk_path
		|> List.map ~f:trail_to_string
		|> List.iter ~f:(printf "%S ")