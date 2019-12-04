open Core

let file_name =
	"input.txt"

let read_file () : string =
	In_channel.read_all file_name

let parse_file (): int list =
	read_file ()
		|> String.split ~on:','
		|> List.map ~f:int_of_string

let put (pos: int) (value: int) (memory: int list) : int list =
	List.concat [
		(List.take memory pos) ;
		[value] ;
		(List.drop memory (pos + 1)) ;
	]

let simple_operation memory op pointer =
	let address_1 =
		List.nth_exn memory (pointer + 1)
	in
	let address_2 =
		List.nth_exn memory (pointer + 2)
	in
	let address_3 =
		List.nth_exn memory (pointer + 3)
	in
	let value_1 =
		List.nth_exn memory address_1
	in
	let value_2 =
		List.nth_exn memory address_2
	in
	put address_3 (op value_1 value_2) memory


let rec process pointer memory =
	match (List.nth_exn memory pointer) with
	| 1 ->
		simple_operation memory ( + ) pointer
			|> process (pointer + 4)
	| 2 ->
		simple_operation memory ( * ) pointer
			|> process (pointer + 4)
	| 99 ->
		memory
	| _ ->
		[]

let rec try_next memory noun verb =
	if noun > 99 then
		-1
	else
		if verb > 99 then
			try_next memory (noun + 1) 0
		else
			let
				result =
					process
						0
						(memory
							|> put 1 noun
							|> put 2 verb
						)
			in
				match result with
				| x :: _ ->
					if x = 19690720 then
						100 * noun + verb
					else
						try_next memory (noun) (verb + 1)
				| [] ->
					-1

let () =
	let
		memory = parse_file ()
	in
	try_next memory 0 0
		|> printf "%d "
	(* input
		|> List.iter ~f:(printf "%d ") *)