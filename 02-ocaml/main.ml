open Core

let file_name =
	"input.txt"

let read_file () : string =
	In_channel.read_all file_name

let parse_file (): int list =
	read_file ()
		|> String.split ~on:','
		|> List.map ~f:int_of_string

let put _pos _value memory =
	memory

let rec process memory pointer =
	match (List.nth_exn memory pointer) with
	| 1 ->
		let address_1 = List.nth_exn memory (pointer + 1) in
		let address_2 = List.nth_exn memory (pointer + 2) in
		let address_3 = List.nth_exn memory (pointer + 3) in
		let value_1 = List.nth_exn memory address_1 in
		let value_2 = List.nth_exn memory address_2 in
		let next_memory = put address_3 (value_1 + value_2) memory in
		process next_memory (pointer + 4)
	| 2 ->
		let address_1 = List.nth_exn memory (pointer + 1) in
		let address_2 = List.nth_exn memory (pointer + 2) in
		let address_3 = List.nth_exn memory (pointer + 3) in
		let value_1 = List.nth_exn memory address_1 in
		let value_2 = List.nth_exn memory address_2 in
		let next_memory = put address_3 (value_1 + value_2) memory in
		process next_memory (pointer + 4)
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
						(memory
							|> put 1 noun
							|> put 2 verb
						)
						0
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