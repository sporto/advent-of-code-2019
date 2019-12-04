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
	| Unknown

let move_to_num move =
	match move with
	| R n -> n
	| L n -> n
	| D n -> n
	| U n -> n
	| Unknown -> 0

let parse_move (input: string) : move =
	let code    = prefix input 1 in
	let num_str = drop_prefix input 1 in
	let num     = int_of_string num_str in
	match code with
	| "R" -> R num
	| "L" -> L num
	| "U" -> U num
	| "D" -> D num
	| _ -> Unknown

let parse_path (input: string) : move list =
	input
		|> String.split ~on:','
		|> List.map ~f:parse_move

let sum_path path =
	path
		|> List.map ~f:move_to_num
		|> List.sum (module Int) ~f:ident

let () =
	read_file ()
		|> List.map ~f:parse_path
		|> List.map ~f:sum_path
		|> List.iter ~f:(printf "%i ")