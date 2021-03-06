open Cmdliner
include Dsl

let generate_dune_inc ~suite =
  let case =
    let open Arg in
    required
    & opt (some string) None
    & info ~doc:"PATH"
        ~docv:
          "The path of the directory containing the [dune] file to be \
           generated, relative to the specification."
        [ "path" ]
  in
  Term.(
    const (fun path ->
        match String.split_on_char '\'' path with
        | [ ""; path; "" ] ->
            let path =
              match path with "" -> [] | _ -> String.split_on_char '/' path
            in
            Engine.emit_dune_inc suite ~path
        | _ -> assert false)
    $ case)

let emit_top_level ~suite =
  Term.(const (fun () -> Bootstrap.perform suite) $ const ())

let declare suite =
  Term.(
    exit
    @@ eval_choice
         ( emit_top_level ~suite,
           Term.info ~doc:"Utilities for testing OCaml PPXs" "scaffold" )
         [
           ( generate_dune_inc ~suite,
             Term.info ~doc:"Emit the correct `dune.inc` file for a test case"
               "generate" );
         ]);
  assert false
