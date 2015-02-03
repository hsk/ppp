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

let rec loop (argv:string array) (i:int) (v:string) : string=
  if i >= Array.length argv
  then v
  else loop argv (i + 1) (v ^ " "^argv.(i))
;;

let cmd =
  
  loop Sys.argv 1 ""
;;
let _ = run ("ocaml "^cmd);;

