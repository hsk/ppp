#load "unix.cma";;
let run cmd =
  let env = Unix.environment () in
  let cmd_out, cmd_in, cmd_err = Unix.open_process_full cmd env in
  close_out cmd_in;
  let cmd_out_descr = Unix.descr_of_in_channel cmd_out in
  let cmd_err_descr = Unix.descr_of_in_channel cmd_err in
  let selector = ref [cmd_err_descr; cmd_out_descr] in
  while !selector <> [] do
    let can_read, _, _ = Unix.select !selector [] [] 1.0 in
    List.iter
      (fun fh ->
         try
           if fh = cmd_err_descr
           then
             Printf.fprintf stderr "%s\n" (input_line cmd_err)
           else
             Printf.fprintf stdout "%s\n" (input_line cmd_out)
         with End_of_file ->
           selector := List.filter (fun fh' -> fh <> fh') !selector)
      can_read
  done;
  let code = match Unix.close_process_full (cmd_out, cmd_in, cmd_err) with
  | Unix.WEXITED(c) -> c
  | Unix.WSIGNALED(c) ->c
  | Unix.WSTOPPED(c) -> c in
  code
;;
let fout = ref stdout;;
let asm_close () =
  close_out !fout;
  fout := stdout
;;
let asm_open filename =
  fout := open_out filename
;;
let asm_p x =
  output_string !fout ("  " ^ x ^ "\n")
;;
let asm x =
  output_string !fout (x ^ "\n")
;;

let run2 cmd = 
	Printf.printf "%s\n" cmd;
	run cmd
;;
type r = {
	name:string;
	user:string;
	repo:string list;
	version:string;
	install:string list;
	uninstall:string list;
	depends: (string * string) list;
};;

let install = function
	| {name=name;user=user;repo=repo;version=version;install=install;uninstall=uninstall;depends=depends} ->
		Printf.printf "name=%s\n" name;
		Printf.printf "user=%s\n" user;
		Printf.printf "version=%s\n" version;

		Printf.printf "repo:\n";

		List.iter (fun cmd ->
			Printf.printf "  %s\n" cmd
		) repo;

		Printf.printf "install:\n";

		List.iter (fun cmd ->
			Printf.printf "  %s\n" cmd
		) install;

		Printf.printf "depends:\n";
		List.iter (fun (name,version) ->
			Printf.printf "  name:%s version:%s\n" name version
		) depends;
		let _ = run2 ("mkdir "^user) in
		let _ = run2 ("cd "^user^";git clone https://github.com/"^user^"/"^(List.hd repo)^".git") in
		let _ = run2 ("cd "^user^"/"^(String.concat "/" repo)^"; ls") in
		()
;;

let uninstall = function
	| {name=name;user=user;repo=repo;version=version;install=install;uninstall=uninstall;depends=depends} ->
		Printf.printf "uninstall:\n";
		List.iter (fun cmd ->
			Printf.printf "  %s\n" cmd
		) uninstall;
;;

let usage () =
	Printf.printf "usage ppp (install | uninstall) \n"
;;

let ppp conf =
	if Array.length Sys.argv < 2 then usage()
	else
		match Sys.argv.(1) with
		| "install" -> install conf
		| "uninstall" -> uninstall conf
		| _ -> usage()
;;

let _ =
	if (Array.length Sys.argv) = 2 then
		match Sys.argv.(1) with
		| "-init" -> run2 "cd /usr/local/lib/; git clone https://github.com/hsk/ppp.git"
		| "-list" -> run2 "cd /usr/local/lib/ppp/; ls"
	else 0
;;

